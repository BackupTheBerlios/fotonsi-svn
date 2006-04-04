class MorcegoController < ApplicationController
  wsdl_service_name 'Morcego'
  web_service_api MorcegoApi
  web_service_scaffold :invoke
  attr_reader :relations
  
  def relations=(new_relations)
    # Enhancement: check validations of new_relations
    @relations = new_relations
  end
  
  def relations_example()
    # Ejemplo
    @relations = {
      "Obra" => {
        :neighbours => %w(promotors suelos), # relaciones que afectan (se llama al método con "send")
                                             # se usará el plural dependiendo del tipo de relación
        :title => "nombre", # forma de obtener el título (método sobre el objeto)
        :controller => 'obra', # controlador y acción a la que
        :action => 'mostrar',  # dirigirse en la URL
        :image => "default.gif", # imagen del nodo
        :description => "descripcion" }, # forma de obtener la descripción (método sobre el objeto)
      "Suelo" => {
        :neighbours => %w(obra),
        :title => "nombre",
        :controller => 'suelo',
        :action => 'mostrar',
        :image => "default.gif",
        :description => "descripcion" }, # forma de obtener la descripción (método sobre el objeto)
      "Promotor" => {
        :neighbours => %w(obra),
        :title => "nombre",
        :controller => 'suelo',
        :action => 'mostrar',
        :image => "default.gif",
        :description => "descripcion" } # forma de obtener la descripción (método sobre el objeto)        
    }  
  end
  
  def initialize(*args)
    super(*args)
    relations_example()
  end
  
  def GetSubGraphExample()
    return {
      "graph"=>{
        "Foton"=>{
          "neighbours"=>%w(Gonzalo Esteban Imo),
          "actionURL"=>"http://www.google.es",
          "description"=>"prueba 1" },
        "Gonzalo"=>{
          "neighbours"=>%w(Foton),
          "type"=>"URLimage" },
        "Esteban"=>{
          "title"=>"otro",
          "neighbours"=>%w(Foton),
          "type"=>"round",
          "color"=>"#00FF00" },
        "Imo"=>{
          "neighbours"=>%w(Foton),
          "type"=>"image" }
      }
    }
  end
  
  def IsNodePresentExample()
    return rand>0.5
  end

  def morcego_node_name(name, id)
    # Returns de morcego name for this class and id
    #{self.class}-#{self.id}
    "#{name}-#{id}"
  end
  
  def find_by_morcego_node_name(node_name)
    # Returns the concrete object (class+id) of this morcego name
    node_name =~ /^(.+)-(.+)$/
    class_name = $1
    id = $2
    begin
      Object.const_get(class_name).find(id)
    rescue
      nil
    end
  end

  def add_to_returned_hash(node, neighbours, returned_hash)
    node_config = relations[node.class.to_s]
    node_name = morcego_node_name(node.class.to_s, node.id.to_s)
    temp = node_config[:title]
    res = {}
    if (not neighbours.empty?)
      res["neighbours"] = neighbours
    end
    res["title"] = node.send(node_config[:title])
    res["nodeType"] = "image"
    res["image"] = node_config[:image]
    res["actionUrl"] = url_for(:controller => node_config[:controller], 
      :action => node_config[:action], :id => node.id)
    res["description"] = node.send(node_config[:description])
    returned_hash[node_name] = res
    returned_hash
  end

  def getSubGraph(nodeName, depth)
    # return GetSubGraphExample()}
    returned_hash = {"graph"=>{}}
    graph_hash = returned_hash["graph"]
    new_nodes_arrays = [] # Vector de nuevos vectores de objetos a tratar
    new_nodes_arrays << [find_by_morcego_node_name(nodeName)]
    parent_nodes = [] # Vector de objetos. Cada objeto corresponde a un vector de objetos new_nodes.
    parent_nodes << nil

    while (depth > 0 && new_nodes_arrays.size > 0)
      actual_nodes_arrays = new_nodes_arrays
      new_nodes_arrays = []
      actual_nodes_arrays.each do |actual_nodes|
        parent_node = parent_nodes.pop
        actual_nodes.each do |node|
          if ! graph_hash.has_key?(morcego_node_name(node.class.to_s, node.id))
            neighbour_morcego_names = []
            if relations[node.class.to_s].has_key?(:neighbours)
              node_class_relations = relations[node.class.to_s][:neighbours]
              neighbour_nodes = []
              node_class_relations.each do |rel|
                if node.methods.include?(rel)
                  res = node.send(rel)
                  if res.kind_of?(Array)
                    neighbour_nodes.concat(res)
                  else
                    neighbour_nodes << res
                  end
                end
              end
              neighbour_morcego_names = neighbour_nodes.map {|i| morcego_node_name(i.class.to_s, i.id)}
              new_nodes_arrays << neighbour_nodes
              parent_nodes << node
            end
            if (! parent_node.nil?) && (! neighbour_morcego_names.include?(morcego_node_name(parent_node.class.to_s, parent_node.id)))
              add_to_returned_hash(node, neighbour_morcego_names.push(morcego_node_name(parent_node.class.to_s, parent_node.id)), graph_hash)
            else
              add_to_returned_hash(node, neighbour_morcego_names, graph_hash)
            end
          end
        end
      end
      depth = depth - 1
    end

    new_nodes_arrays.each do |new_nodes|
      parent_node = parent_nodes.pop
      if parent_node.nil?
        new_nodes.each do |node|
          if ! graph_hash.has_key?(morcego_node_name(node.class.to_s, node.id))
            add_to_returned_hash(node, [], graph_hash)
          end
        end
      else
        new_nodes.each do |node|
          if ! graph_hash.has_key?(morcego_node_name(node.class.to_s, node.id))
            add_to_returned_hash(node, [morcego_node_name(parent_node.class.to_s, parent_node.id)], graph_hash)
          end
        end
      end
    end
    
    returned_hash
    
  end

  def isNodePresent(node_name)
    # return IsNodePresentExample()
    node = find_by_morcego_node_name(node_name)
    not node.nil?
  end
end
