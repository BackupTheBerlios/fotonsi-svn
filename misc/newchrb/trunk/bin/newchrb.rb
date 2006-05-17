#!/usr/bin/ruby -w

require 'highline'
require 'rucola'
require 'foton/plugin_utils'

require 'newchrb'
require 'chrb_types/base'

@conf = Rucola::Conf.new('newchrb')
ChrbTypes::Base.chrb_repo_dir = '.'

chrbtype = Foton::PluginUtils.load_plugin('Foton', ChrbTypes)
attrs = NewChrb.retrieve_chrb_property_values(chrbtype.properties)

chrbtype.create('tmp/nuevo_chrb', attrs)
say("Done.")
