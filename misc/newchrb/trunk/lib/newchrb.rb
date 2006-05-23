require 'highline/import'

# Standard definitions for +newchrb+
module NewChrb
    VERSION = 0.1

    # Asks the user for the values for the new chrb properties, and returns a
    # hash with those values
    def retrieve_chrb_property_values(prop_list)
        values = {}
        prop_list.each {|p| values[p.name] = p.default}

        catch :done do
            loop do
                prop_list.each do |prop|
                    case prop.type
                    when :integer
                        value = ask(prop.description, lambda {|r| r.to_i}) {|q| q.default = prop.default}
                    when :boolean
                        choose do |menu|
                            menu.layout  = :one_line
                            menu.prompt  = "#{prop.description} " + (values[prop.name] ? "[y] " : "[n] ")
                            menu.default = values[prop.name] ? 'y' : 'n'
                            menu.choice 'y' do value = true  end
                            menu.choice 'n' do value = false end
                        end
                    else
                        value = ask(prop.description) {|q| q.default = prop.default}
                    end
                    values[prop.name] = value
                end

                say("--------------------")
                say("New chrb properties:")
                values.each_pair do |key, val|
                    say("#{key} = #{val}")
                end

                choose do |menu|
                    menu.layout = :one_line
                    menu.prompt = "Is it OK? "
                    menu.choice 'y' do throw :done   end
                    menu.choice 'n'
                end
            end
        end
        values
    end

    module_function :retrieve_chrb_property_values
end
