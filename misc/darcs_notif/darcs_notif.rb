#!/usr/bin/ruby

require 'net/smtp'

EMAILS = %w(eduardo@foton.es zoso@foton.es mvazquez@foton.es doc@foton.es tolo@foton.es jarbelo@foton.es ialiende@foton.es rdale@foton.es ancor@foton.es knut@foton.es ivan@foton.es wage@foton.es setepo@gmail.com alberto@foton.es)

Dir["*"].each {|basedir|
    next unless File.directory?(basedir + "/_darcs")

    patchs = []
    darcs = `darcs changes --repodir="#{basedir}" -v --matches 'date "10 minutes ago"'`
    darcs.each_line {|line|
        patchs << '' if /^\w+ \w+.*@.*$/ === line    # Usamos esta regex para separar los parches
        patchs.last << line
    }

    patchs.each {|patch|
        # Enviamos los emails para este 
        Net::SMTP.start('localhost', 25) { |smtp|
            # Analizamos el parche.
            # La primera línea será la fecha y el autor del commit
            # La segunda el nombre del parche
            # El resto... pues el resto

            if /^(.*?)\s+(\S+@\S+)\s*$\s*\*?\s*(.*)$/ === patch
                date = $1
                author = $2
                name = $3
                msg = ''

                msg << "From: #{author}\n"
                msg << "To: #{EMAILS.join(",")}\n"
                msg << "Subject: [darcs fotón] [#{basedir}] #{name}\n"
                msg << "\n\n"
                msg << patch

                smtp.send_message msg, author, *EMAILS
            end

        }
    }
}
