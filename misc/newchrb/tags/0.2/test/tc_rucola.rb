# Code Generated by ZenTest v. 3.2.0
#                 classname: asrt / meth =  ratio%
#                Rucola::Conf:    0 /    4 =   0.00%

require 'test/unit' unless defined? $ZENTEST and $ZENTEST

require 'rucola'

module TestRucola
  class TestConf < Test::Unit::TestCase
    def test_class_configuration_dirs
        assert_equal(Rucola::CONFIGURATION_DIRS,
                     Rucola::Conf.configuration_dirs,
                                        "configuration_dirs default value")
    end

    def test_class_configuration_dirs_equals
        new_conf = {:test => [['test/conf'], lambda {|foo| foo}]}
        Rucola::Conf.configuration_dirs = new_conf
        assert_equal(new_conf, Rucola::Conf.configuration_dirs,
                                        "configuration_dirs=(conf)")
    end

    def test_read_conf
        test_conf_spec = {:test => [['test/conf'], lambda {|foo| "#{foo}.conf"}]}
        Rucola::Conf.configuration_dirs = test_conf_spec
        r = Rucola::Conf.new('testapp')
        assert_equal({:foo => 'bar', :qux => 2}, r.to_hash)
    end

    def test_symbols_and_strings
        test_conf_spec = {:symbols_and_strings => [['test/conf'], lambda {|foo| "#{foo}.conf"}]}
        Rucola::Conf.configuration_dirs = test_conf_spec
        r = Rucola::Conf.new('symbols_and_strings')
        assert_equal('symbol', r[:symbol],  "Read symbol")
        assert_equal('string', r['string'], "Read string")
        assert_equal('symbol', r['symbol'], "Read symbol as string")
        assert_equal('string', r[:string],  "Read string as symbol")
    end
  end
end
