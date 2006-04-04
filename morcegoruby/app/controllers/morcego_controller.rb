class MorcegoController < ApplicationController
  wsdl_service_name 'Morcego'
  web_service_api MorcegoApi
  web_service_scaffold :invoke
  attr_reader :relations

  def relations=(new_relations)
    new_relations.each_pair do |class_name, opts|
      if Object.const_get(class_name).nil? then
        raise TypeError
      end
      opts[:type] ||= "urlimage"
      opts[:image] ||= "/images/morcego/default.gif"
    end
    @relations = new_relations
  end
  def relations_example()
    # Ejemplo
    return {
      "Obra" => {
        :neighbours => %w(promotors suelos), # relaciones que afectan (se llama al método con "send")
                                             # se usará el plural dependiendo del tipo de relación
        :title => "nombre", # forma de obtener el título (método sobre el objeto)
        :controller => 'show', # controlador y acción a la que
        :action => 'a',  # dirigirse en la URL
        :type => 'urlimage', # tipo de nodo (urlimage por defecto)
        :image => "/images/morcego/default.gif", # imagen del nodo
        :description => "descripcion" }, # forma de obtener la descripción (método sobre el objeto)
      "Suelo" => {
        :neighbours => %w(obra),
        :title => "nombre",
        :controller => 'show',
        :action => 'b',
        :type => 'urlimage', 
        :image => "/images/morcego/murc.gif",
        :description => "descripcion" }, # forma de obtener la descripción (método sobre el objeto)
      "Promotor" => {
        :neighbours => %w(obra),
        :title => "nombre",
        :controller => 'show',
        :action => 'c',
        :type => 'round', 
        # :image => "/images/morcego/default.gif",
        :description => "descripcion" } # forma de obtener la descripción (método sobre el objeto)        
    }  
  end

  def initialize(*args)
    super(*args)
    self.relations = relations_example
  end


  def morcego_node_name(node)
    # Returns de morcego name for this object
    # Enhancement: Heritance from the ActiveRecord::Base
    "#{node.class.to_s}-#{node.id}"
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
    node_name = morcego_node_name(node)
    temp = node_config[:title]
    res = {}
    if (not neighbours.empty?) then
      res["neighbours"] = neighbours
    end
    # ToDo: Hacer comprobaciones
    begin
      res["title"] = node.send(node_config[:title])
      if res["title"].empty? then res.delete("title") end
    rescue
      res["title"] = res.delete("title")
    end
    res["type"] = node_config[:type]
    res["image"] = node_config[:image] unless ! node_config[:image]
    res["actionUrl"] = url_for(:controller => node_config[:controller], 
      :action => node_config[:action], :id => node.id) unless
      (!node_config[:controller]) && (!node_config[:action]) && (!node.id)
    begin
      res["description"] = node.send(node_config[:description])
      if res["description"].empty? then res.delete("description") end
    rescue
      res.delete("description")
    end
    returned_hash[node_name] = res
    returned_hash
  end

# Web Services Implementation #

  # nodeName = Nombre del nodo en formato "morcego name"
  # depth = Profundidad de búsqueda en la vecindad
  # RETURNED = A hash with all the nodes and information
  def getSubGraph(nodeName, depth)
    graph_hash = {} # Returned hash
    new_nodes_arrays = [] # Vector de nuevos vectores de objetos a tratar
    new_nodes_arrays << [find_by_morcego_node_name(nodeName)]
    parent_nodes = [] # Vector de objetos. Cada objeto corresponde a un vector de objetos new_nodes.
    parent_nodes << nil

    while (depth > 0 && new_nodes_arrays.size > 0)
      actual_nodes_arrays = [] # Vector de vectores de nodos a tratar en esta iteración
      actual_nodes_arrays = new_nodes_arrays
      new_nodes_arrays = []
      actual_nodes_arrays.each do |actual_nodes| # Vector de nodos a tratar
        parent_node = parent_nodes.pop # Nodo padre de los nodos tratados a continuación
        actual_nodes.each do |node| # Nodo a tratar
          # Evitamos la redundancia cíclica (nodos ya tratados)
          if ! graph_hash.has_key?(morcego_node_name(node))
            # Si existen vecinos, los tratamos
            if relations[node.class.to_s].has_key?(:neighbours)
              node_class_relations = relations[node.class.to_s][:neighbours]
              # Vector de nodos vecinos a "node"
              neighbour_nodes = []
              # Vector de nombres tipo morcego de los nodos del vector neighbour_nodes
              neighbour_morcego_names = []
              # Metemos todos los objetos relacionados con "node" en "neighbour_nodes"
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
              neighbour_morcego_names = neighbour_nodes.map {|i| morcego_node_name(i)}
              # Los nodos vecinos se meten como un array para tratar en la siguiente iteración
              # y también el padre de ellos, de tal manera que cada vector de nodos tiene un padre en común
              new_nodes_arrays << neighbour_nodes
              parent_nodes << node
            end
            # Si tiene padre y el padre no está en la lista de los vecinos tratados, posiblemente porque no tenía vecinos
            # entonces añadimos como vecino al padre, si no simplemente lo añadimos con los vecinos
            if (! parent_node.nil?) && (! neighbour_morcego_names.include?(morcego_node_name(parent_node)))
              add_to_returned_hash(node, neighbour_morcego_names.push(morcego_node_name(parent_node)), graph_hash)
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
      # En la última iteración, no hay vecinos excepto el padre
      if parent_node.nil?
        neighbours = []
      else
        neighbour_nodes = [morcego_node_name(parent_node)]
      end
      # Evitamos la redundancia cíclica (nodos ya tratados)
      new_nodes.each do |node|
        if ! graph_hash.has_key?(morcego_node_name(node))
          add_to_returned_hash(node, neighbour_nodes, graph_hash)
        end
      end
    end
    
    {"graph" => graph_hash}
    
  end
  def isNodePresent(node_name)
    node = find_by_morcego_node_name(node_name)
    not node.nil?
  end
end