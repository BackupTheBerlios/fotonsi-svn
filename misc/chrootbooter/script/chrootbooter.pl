#!/usr/bin/perl -w

use strict;

=pod
chrootbooter - Script to "boot" chroots
=cut

our $VERSION = 0.01;

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
my $chroot_repo = $options{d} || $conf->{repo}->{dir} || do {
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
my $filter     = $conf->{init_scripts}->{filter} || 'halt|sendsigs|hwclock';
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
    print "Processing $chroot...\n" unless $options{q};
    foreach my $init_script (get_init_scripts($chroot, $init_level, $filter)) {
        print "Executing $init_script in chroot $chroot...\n" if $options{v};
	system("$chroot_cmd $chroot $init_script $action") unless $options{n};
    }
}
