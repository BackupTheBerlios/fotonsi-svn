#!/usr/bin/perl -w

use strict;

=head1 TITLE

chrootbooter - Script to "boot" chroots

=head1 SYNOPSIS

 chrootbooter start
 chrootbooter start some_chroot
 chrootbooter stop /srv/chroots/some_chroot
 chrootbooter -d /src/more_chroots stop some_chroot

=head1 CALLING CONVENTION

There are three ways to call C<chrootbooter>:

=over 4

=item C<chrootbooter I<action>>

It acts on every C<chroot> found in the C<chroot> repository (given in the
configuration file or with the C<-d> switch).

=item C<chrootbooter I<action> I<some_chroot>>

It acts on the given C<chroot>, relative to the C<chroot> repository.

=item C<chrootbooter I<action> I<absolute_directory>>

It acts on the given C<chroot>, regardless of the C<chroot> repository.

=back


=head1 ACTIONS

There are two actions: C<start> and C<stop>. The first one calls every init
script on level 3 on every C<chroot> it's going to act on. On the other hand,
C<stop> calls every init script on level 0 on every C<chroot> it's going to act
on. It's strongly recommended that every C<chroot> is checked for non-used init
scripts, and it's kept clean.

In both cases, init scripts whose name matches the filter regular expression
aren't touched.

The C<-n> switch is very useful to try out and see what init scripts would be
called.


=head1 CONFIGURATION FILES

There are two kinds of configuration files for C<chrootbooter>:

=over 4

=item Host configuration files

Currently only one, C</etc/chrootbooter.ini>. It has generic configuration
parameters for the C<chrootbooter> executable.

=item Per-chroot configuration files

Currently only one, C</etc/chrb/pre.conf>, inside each C<chroot>. It has
specific configuration for each C<chroot>.


=head2 C</etc/chrootbooter.ini>

In this configuration file you can specify paths and init script parameters.
Currently there are three configuration keys:

 [path]
 repo = /home/chroot
 chroot_bin = /usr/sbin/chroot

 [init_scripts]
 filter = halt|sendsigs|hwclock|umountfs|umountnfs

The first one specifies the directory where the chroot reside. The second one,
the absolute path for the C<chroot> executable. The third one is a filter (a
Perl regular expression) of init scripts that should be always ignored.


=head2 C</etc/chrb/pre.conf>

This configuration file stores information for each C<chroot>. It currently has
two possible directives:

 ensure_preload /some/path/to/libsomething.so
 bind /dev /dev

The C<ensure_preload> directive specifies some library that should be loaded
with the C<LD_PRELOAD> trick. When present, C<chrootbooter> checks if the
library is in the C<chroot>, tries to copy it from the host if not, and adds it
to C</etc/ld.so.preload> inside the C<chroot>, if it's not already.

The C<bind> directive mounts (with the C<--bind> option) the specified host
directory (the first one) in the given C<chroot> directory (the second one),
when starting, or umount when stopping. If both are the same, it can be
specified as C<bind /onedir>.

=back


=head1 LICENSE

 Copyright (C) 2005 Esteban Manchado Velázquez <zoso@foton.es>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

=cut

our $VERSION = 0.02;

use File::Copy qw(copy);

sub usage {
    print STDERR <<EOUSAGE;
Usage: chrootbooter [-v] [-q] [-n] [-d chroot_repo_dir] start|stop [chroot]

Examples:
   chrootbooter -d /var/chroots start
   chrootbooter stop /var/chroots/my_dev_chroot
   chrootbooter stop my_dev_chroot

Options:
   -n         Do nothing
   -v         Verbose
   -q         Quiet
EOUSAGE
    exit 1;
}

# Get only dirs (not hidden) inside directory $dir
sub get_dirs {
    my ($dir) = @_;
    opendir D, $dir;
    my @dirs = grep { -d $_ }                   # Only dirs
                    map { $dir.'/'.$_ }         # Add repo dir
                        grep { $_ !~ /^\./ }    # Ignore hidden dirs
                             readdir D;
    closedir D;
    @dirs;
}

# Get init script paths
sub get_init_scripts {
    my ($chroot, $init_level, $filter) = @_;

    my $dir = $chroot."/etc/rc$init_level.d";
    opendir D, $dir;
    my @dirs = grep { -l $_ }               # Only symbolic links
                    map { $dir.'/'.$_ }     # Add chroot dir
                        # Sort by order number, but put 'S' scripts last
                        sort { my ($order_a, $order_b) = (substr($a, 1, 2),
                                                          substr($b, 1, 2));
                               $order_a *= 100 if substr($a, 0, 1) eq 'S';
                               $order_b *= 100 if substr($b, 0, 1) eq 'S';
                               $order_a <=> $order_b }
                             grep { $_ !~ /^\./ }   # Filter out hidden files
                                  readdir D;
    closedir D;

    # Drop chroot basedir, then apply filter
    grep {
            if ($_ =~ $filter) {
                print STDERR "Warning: Ignoring init script $_\n";
                0;
            }
            else {
                1;
            }
         }
         map { $_ =~ s/^$chroot//g; $_ }
             @dirs;
}

# Normalize chroot list
sub normalize_chroots {
    my ($chroot_repo, @chroot_list) = @_;

    # Ignore non-directory entries
    grep { if (-d $_) {
	       1
	   }
	   else {
    	       print STDERR "Warning: skipping '$_': not a directory\n";
	       0
	   }
	 }
	 # Add chroot repo path if it isn't an absolute path
         map { $_ =~ m|^/| ? $_ : $chroot_repo.'/'.$_ }
             @chroot_list;
}


# Read the chroot configuration file
sub read_pre_config {
    my ($path) = @_;

    open(F, $path) || return undef;
    my %config = ('bind' => {}, 'preload' => []);
    my $linenumber = 0;
    foreach my $line (<F>) {
        $linenumber++;
        $line =~ s/\s#.*//o;
        $line =~ s/^\s+//o;
        $line =~ s/\s+$//o;
        if ($line =~ /^bind\s+([\/a-zA-Z_]+)(\s+([\/a-zA-Z_]+))?$/) {
            my ($path, $chrpath) = ($1, $3);
            $chrpath ||= $path;
            $config{bind}->{$path} = $chrpath;
        }
        elsif ($line =~ /^ensure_preload\s+(.+)$/) {
            push @{$config{preload}}, $1;
        }
        elsif ($line =~ /^\s*$/) {
            # Do nothing
        }
        else {
            print STDERR "$path: $linenumber: Syntax error\n";
        }
    }
    close F;

    \%config
}


# Returns if the given directory is bound
sub is_bound {
    my ($chroot_dir) = @_;

    my $bound = 0;
    open(F, "/proc/mounts") or die "Can't open /proc/mounts";
    while (<F>) {
        $bound = 1 if / $chroot_dir /;
    }
    close F;

    $bound;
}


# Ensure some dir is bound. If it's not, bind it. Returns if the directory was
# already bound
sub ensure_bound {
    my ($dir, $chroot_dir) = @_;

    my $bound = is_bound($chroot_dir);
    if (!$bound) {
        if (system "mount --bind $dir $chroot_dir") {
            print STDERR "Couldn't bind directory $dir to $chroot_dir\n";
            exit 1;
        }
    }

    $bound;
}


# Tries to unbind a directory. Returns if the directory could be unbound
sub unbind {
    my ($chroot_dir) = @_;

    if (is_bound($chroot_dir)) {
        return 0 if system "umount $chroot_dir";
    }
    return 1;
}


# Returns the bind dir list for the given chroot and chroot configuration
sub bind_dirs {
    my ($chroot, $chroot_conf) = @_;

    my @list;
    foreach my $dir (keys %{$chroot_conf->{bind}}) {
        my $chroot_dir = "$chroot/$chroot_conf->{bind}->{$dir}";
        $chroot_dir =~ s;//+;/;go;
        push @list, [$dir, $chroot_dir];
    }
    @list;
}

# MAIN PROGRAM ---------------------------------------------------------------



# Load config
use Config::Tiny;
my $conf_path = '/etc/chrootbooter.ini';
my $conf = Config::Tiny->read($conf_path);
defined $conf || do {
    print STDERR "Can't read configuration file '$conf_path'\n";
    exit;
};


# Parse arguments
# Options
use Getopt::Std;
my %options;
getopts('nqvd:', \%options);
$options{v} = 1 if $options{n};     # -n implies -v
# Rest of arguments
my ($action, @chroots) = @ARGV;
$action ||= '';
if ($action ne 'start' && $action ne 'stop') {
    usage;
}

# Set chroot repository directory
my $chroot_repo = $options{d} || $conf->{path}->{repo} || do {
    print STDERR "You haven't specified a chroot repository\n";
    exit 1;
};
if (!-d $chroot_repo) {
    print STDERR "Can't find '$chroot_repo' or it isn't a directory\n";
}


# Decide chroots to act on
if (@chroots) {
    @chroots = normalize_chroots($chroot_repo, @chroots);
}
else {
    @chroots = get_dirs($chroot_repo);
}

# Regexp to filter out potencially dangerous scripts
my $filter     = $conf->{init_scripts}->{filter} || 'halt|sendsigs|hwclock|umountfs|umountnfs';
# Path for chroot program
my $chroot_cmd = $conf->{path}->{chroot_bin}     || '/usr/sbin/chroot';
if ($chroot_cmd !~ m;^/;) {
    print STDERR "Warning: Non-absolute path for chroot: trying /usr/sbin/$chroot_cmd\n";
    $chroot_cmd = "/usr/sbin/".$chroot_cmd;
}
if (!-x $chroot_cmd) {
    print STDERR "Can't find $chroot_cmd. Please specify the absolute path in\n";
    print STDERR "the configuration directive 'chroot_bin', under [path]\n";
}
# Init level
my $init_level = $action eq 'start' ? 3 : 0;
foreach my $chroot (@chroots) {
    my $number_equals = 78 - length("Processing $chroot ");
    print "Processing $chroot ", ("=" x $number_equals), "\n" unless $options{q};

    # Chroot configuration
    my $chroot_conf = undef;
    my $conf_dir = "$chroot/etc/chrb";
    if (-d $conf_dir) {
        my $conf_file = "$conf_dir/pre.conf";
        if (-r $conf_file) {
            $chroot_conf = read_pre_config($conf_file);
            if (! ref $chroot_conf) {
                print STDERR "WARNING: wrong configuration for chroot $chroot\n";
            }
        }
    }
    else {
        print STDERR "WARNING: chroot $chroot doesn't have a configuration directory\n" unless $options{q};
    }

    # Pre-tasks (configuration-driven)
    if (ref $chroot_conf) {
        if ($action eq 'start') {
            foreach my $dir_pair (bind_dirs($chroot, $chroot_conf)) {
                my $ret = ensure_bound($dir_pair->[0], $dir_pair->[1]);
                if ($ret and !$options{q}) {
                    print STDERR "Skipping already bound directory $dir_pair->[1]\n";
                }
            }

            foreach my $preload (@{$chroot_conf->{preload}}) {
                # First, check it's already there. If not, try to copy from
                # host filesystem
                if (! -r "$chroot/$preload") {
                    if (-r $preload) {
                        print "WARNING: Copying $preload to $chroot\n"
                                unless $options{q};
                        copy $preload, "$chroot/$preload";
                    }
                    else {
                        print STDERR "ERROR: Can't find $preload either in $chroot nor in host filesystem\n";
                        exit 1;
                    }
                }

                # Supposedly, it's already there. Now check if it's loaded from
                # /etc/ld.so.preload
                my $preload_file = "$chroot/etc/ld.so.preload";
                open F, $preload_file;
                my @preload_lines = <F>;
                close F;
                # If not present, simply add it at the end
                if (! grep /^$preload$/, @preload_lines) {
                    print "Adding $preload to $preload_file\n"
                            unless $options{q};
                    open(F, ">>$preload_file") or
                            die "Can't open $preload_file for writing";
                    print F $preload, "\n";
                    close F;
                }
            }
        }
    }

    # Execute init scripts
    my @init_scripts = get_init_scripts($chroot, $init_level, $filter);
    @init_scripts || print STDERR "WARNING: Can't find any init script in init level $init_level in $chroot\n";
    foreach my $init_script (@init_scripts) {
        print "Executing $init_script in chroot $chroot...\n" if $options{v};
	system("$chroot_cmd $chroot $init_script $action") unless $options{n};
    }

    if (ref $chroot_conf and $action eq 'stop') {
        foreach my $dir_pair (bind_dirs($chroot, $chroot_conf)) {
            my $ret = unbind($dir_pair->[1]);
            if (! $ret and !$options{q}) {
                print STDERR "WARNING: Couldn't unbind directory $dir_pair->[1]\n";
            }
        }
    }
}
