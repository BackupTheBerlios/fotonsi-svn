# WebWare plugin for FOSC

$types = { "id"       => "IntCol",
           "int"      => "IntCol",
           "varchar"  => "StringCol",
           "memo"     => "StringCol",
           "currency" => "CurrencyCol",
           "datetime" => "DateTimeCol",
           "binary"   => "StringCol",       # [s: no sé si ésta es la más correcta]
           "float"    => "FloatCol",
         }

module Fosc
    module Plugins
        class Webware < BasePlugin
            def export(bd)
                bd.tables.each do |t|
                    tname = t.name.gsub('t_', "")
                    pFile = File.new("form_#{tname}.py", "w")
                    tFile = File.new("form_#{tname}.tmpl", "w")
                    pFile.print <<SALIDA
# -*- coding: latin1 -*-

'''
This module has class definitions for webware form.

Generated at #{Time.new.to_s}.
Contains the following classes:
SALIDA
                    pFile.print "            * form_#{tname}(#{@options['aplic']}Page)"
                    pFile.print <<SALIDA

'''
from lib.#{@options['aplic'].capitalize} import #{@options['aplic']}Page

class form_#{tname}(#{@options['aplic']}Page):

    def titulo(self):
        return "#{@options['aplic']}::#{tname}"

    def writeContent(self):

        #Obtenemos una instancia de Pos
        iface = self.GetIface()

        # Definimos los widgets que controlarán los datos del usuario
        from plantillas.form_#{tname} import form_#{tname}

        #incorporamos el espacio de nombres
        from MCWidgets import Form, Widgets

        t = form_#{tname}()
        form = Form.Form('f', args = {'trim_spaces': 1})
        request = self.request()
        response = self.response()
        form.define_form_values(request.fields())
        form.add_widget(Widgets.ToolTips, 'tootips')

SALIDA
                    tFile.print <<SALIDA
         
        <form method="post">
        <fieldset>
        <legend>#{tname}</legend>
        <div class="fondo">
        <table class="basica">

SALIDA
                    contador = 0
                    t.fields.each do |f|
                        contador +=1
                        type = f.type

                        params = []

                        if ((not f.attributes.include?("notnull")) or f.attributes.include?('default'))
                            params << "default = DefaultValue"
                        end
                        formato = ""
                        case f.type
                            when 'id'
                                    tipo = "Numeric"
                            when 'int'
                                    tipo = "Numeric"
                            when 'smallint'
                                    tipo = "Numeric"
                            when 'float'
                                    tipo = "Numeric"
                            when 'currency'
                                    tipo = "Numeric"
                            when 'memo'
                                    tipo = "TextArea"
                                    formato = "'cols': '40', 'rows':  '4'"
                            when 'datetime'
                                    tipo = "DateTimeBox"
                                    tipo = "DateBox"
                            when 'date'
                                    tipo = "DateBox"
                            when 'time'
                                    tipo = "TimeBox"
                                    tipo = "DateBox"
                            when 'binary'
                                    tipo = "TextBox"
                            when 'bool'
                                    tipo = "CheckBox"
                            else
                                    tipo = "TextBox"
                        end
                        if f.reference
                            tipo = "SelectBox"
                            formato ="'options': [
                                        ('1', 'Opcion 1'),
                                        ('2', 'Opcion 2'),
                                        ('3', 'Opcion 3'),
                                        ('4', 'Opcion 4')
                                        ],
                                        'selected': '1'"
                        end
         
                        pFile.print <<SALIDA
                        
        form.add_widget(Widgets.#{tipo}, '#{f.name}',
            {
                'label':         '#{f.name}:',
                'htmlhelp':      'Ayuda_de_#{f.name}',
                'tabindex' :     #{contador},
                #{formato}
            })

SALIDA

                        tFile.print <<SALIDA

        <tr>
                <td>\$form.W.#{f.name}.get_label</td>
                <td>\$form.#{f.name}</td>
        </tr>

SALIDA
                    end
                    pFile.print <<SALIDA

        form.add_widget(Widgets.ListMultiCol, 'listado',
        {
            'order': {
                        'key':        '#{t.fields[0].name}',
                        'reverse':    'n',
                        'url':        'form_#{tname}',
                        'extra_args': {} },
            'columns': [
SALIDA

                    t.fields.each do |f|
                        pFile.print "                 {'key': '#{f.name}', 'name': '#{f.name}'},\n";
                    end

                    ntabla = tname.capitalize

                    pFile.print <<SALIDA
                       ],
                       'data': iface.Get#{ntabla}(),
            'class': 'basica'
        })
SALIDA

                pFile.print <<SALIDA

        t.form = Form.FormTemplate(form)
        self.write(str(t))
                        
SALIDA
                tFile.print <<SALIDA

        <tr>
        <td colspan="2">
        <div id="botonera">
                <input type="button" value="Nuevo" />
                <input type="button" value="Modificar" />
        </div>
        </td>
        </tr>

        <tr>
        <td colspan="2">
                \$form.listado
        </td>
        </tr>

        </table>
        </div>
        </fieldset>
        </form>

SALIDA

                    pFile.close
                    tFile.close
                end
            end
        end
    end
end
