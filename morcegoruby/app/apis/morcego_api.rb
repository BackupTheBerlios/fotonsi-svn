class MorcegoApi < ActionWebService::API::Base
  inflect_names false   # No CamelCase

  api_method :getSubGraph,
              :expects => [{:nodeName => :string}, {:depth => :int}],
              :returns => [Hash]
  api_method :isNodePresent,
              :expects => [{:nodeName => :string}],
              :returns => [:bool]
end
