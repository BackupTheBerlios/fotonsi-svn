module MorcegoHelper

  # Create the HTML code for a morcego applet
  # info: codebase, archive, width, height and code to create the applet tag
  # params: parameters of the applet to create the param tags
  # returns: HTML code to embed the applet
  def morcego_applet(info, params)
    # Initialize default values
    info["codebase"] ||= "/"
    info["archive"] ||= "/morcego.jar"
    info["code"] ||= "br.arca.morcego.Morcego"
    info["width"] ||= "800"
    info["height"] ||= "600"
    params["serverUrl"] ||= "http://" + request.env_table["HTTP_HOST"] + "/morcego/api"
    params["startNode"] ||= "morcego"
    
    applet_tag(info, params)
  end

  # Create the HTML code for an Applet
  # info: codebase, archive, width, height and code to create the applet tag
  # params: parameters of the applet to create the param tags
  def applet_tag(info, params)
    # Initialize default values
    info["codebase"] ||= "/"
    info["width"] ||= "800"
    info["height"] ||= "600"
    
    # Create the HTML
    r = <<EOD
      <applet codebase="#{info["codebase"]}"
      archive="#{info["archive"]}"
      code="#{info["code"]}"
      width="#{info["width"]}"
      height="#{info["height"]}">
EOD

    params.each_pair do |key, value|
      r += <<EOD
        <param name="#{key}"
        value="#{value}" />
EOD
    end

    r += "</applet>\n"

  end

  # Create the HTML code to make the iframe and javascript for morcego applet
  # control_window_name: name of the iframe where the applet will load the document
  # destination_name: desition name of the div where morcego will copy the content
  def morcego_iframe(control_window_name, destination_name)
    control_window_name ||= "morcego"
    destination_name ||= "morcego-destination"
    return <<EOD
      <iframe name="#{control_window_name}" id="#{control_window_name}"
      onload="morcegoNavigate();" style="display: none;"></iframe>
	  <div id="#{destination_name}"></div>
	  <script language="JavaScript">
	  function morcegoNavigate() {
	      var cont = window.frames.#{control_window_name}.document.documentElement;
	      document.getElementById('#{destination_name}').innerHTML = cont.innerHTML;
	  }
	  </script>
EOD
  end
end
