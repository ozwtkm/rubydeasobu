require 'minitest/autorun'
#require 'securerandom'
require 'pry'
require 'pp'

#require_relative '../model/monster' 
#require_relative '../_util/environment'
require_relative '../_util/validator'
#require_relative '../server' # もろもろrequireしてくれる

# あとで別ファイルに引っ越し
class Provisioner
  def self.set_Environment
    Environment.set("pro") #Todo testに相当するenvironmentも用意

    Log.set_log(STDOUT)
  end
end


# あとで別ファイルに引っ越し
class Base_unittest < Minitest::Test
  def setup()
    Provisioner.set_Environment
  end

  def teardown()
    #SQL_master.commit
    SQL_master.close

    #SQL_transaction.commit
    SQL_transaction.close
  end
end



class Validate_nilTest < Base_unittest
  def setup()
    #super
  end
  
  def teardown()
    #super
  end


  def test_validate_nil_valid_value() # 帰ってくるリストはちゃんとしたリストモンスターリストなのか　（そもそもテストすべき項目？
    key = "hoge"
    valuearray = ["aaa", 1, {}, [], Object.new]

    valuearray.each do |value|
        assert_nil(Validator.validate_nil(key, value))
    end
  end


  def test_validate_nil_invalid_value()
    key = "hoge"
    value = nil

    assert_raises(){
        Validator.validate_nil(key, value)
    }

    begin
        Validator.validate_nil(key, value)
    rescue => e
        assert_equal(Error_input_nil, e.class)
        assert_equal("hogeがnilだよ", e.message)
    end
  end
end



class Test_validate_SQL_error < Base_unittest
    def setup()
        #super
      end
      
      def teardown()
        #super
      end

      def test_validate_SQL_error_valid_data_multi_true()
        is_multi_line = true
        record_count = 2

        assert_nil(Validator.validate_SQL_error(record_count, is_multi_line: is_multi_line))
      end

      def test_validate_SQL_error_valid_data_multi_false()
        is_multi_line = false
        record_count = 1

        assert_nil(Validator.validate_SQL_error(record_count, is_multi_line: is_multi_line))
      end

      def test_validate_SQL_error_invalid_data_multi_true()
        is_multi_line = true
        record_counts = [0, -2, 2.0, [2]]

        record_counts.each do |record_count|
            assert_raises(){
                Validator.validate_SQL_error(record_count, is_multi_line: is_multi_line)
            }
        end
      end
end