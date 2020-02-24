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

    begin
        Validator.validate_nil(key, value)
        raise
    rescue => e
        assert_equal(Error_input_nil, e.class)
        assert_equal("hogeがnilだよ", e.message)
    end
  end
end



class Validate_SQL_errorTest < Base_unittest
    def setup()
        #super
    end
    
    def teardown()
        #super
    end


    # 本来、record_countはいろんな形式を想定しなきゃいけないが、
    # 仕様上Integerしか来ないことが保障されてるのでテストケースもその前提
    def test_validate_SQL_error_valid_data_multi_true()
        record_count = 2

        assert_nil(Validator.validate_SQL_error(record_count, is_multi_line: true))
    end

    def test_validate_SQL_error_valid_data_multi_false()
        record_count = 1

        assert_nil(Validator.validate_SQL_error(record_count, is_multi_line: false))
    end

    def test_validate_SQL_error_invalid_data_not_found()
        record_count = 0 
        
        # is_multi_line: true 
        begin
            Validator.validate_SQL_error(record_count, is_multi_line: true)
            raise
        rescue => e
            assert_equal(Error_not_found, e.class)
            assert_equal("データちゃんと取ってこれなかった", e.message)
        end
        
        # is_multi_line: false
        begin
            Validator.validate_SQL_error(record_count, is_multi_line: true)
            raise
        rescue => e
            assert_equal(Error_not_found, e.class)
            assert_equal("データちゃんと取ってこれなかった", e.message)
        end
    end

    def test_validate_SQL_error_invalid_data_over_count()
        record_count = 2

        begin
            Validator.validate_SQL_error(record_count, is_multi_line: false)
            raise
        rescue => e
            assert_equal(Error_over_count, e.class)
            assert_equal("いっぱい取れちゃったんですがそれは", e.message)
        end
    end
end




class Validate_special_characterTest < Base_unittest
    def setup()
        #super
    end
    
    def teardown()
        #super
    end

    def test_validate_special_character_valid_value
        key = "hoge"
        value = "abcABC012_@"

        assert_nil(Validator.validate_special_character(key, value))
    end

    # 本来はvalueにそもそも文字列以外がくることも想定すべき
    def test_validate_special_character_invalid_value
        key = "hoge"
        values = [" a", "a ", "/a", "あ"]

        values.each do |value|
            begin
                Validator.validate_special_character(key, value)
                raise
            rescue => e
                assert_equal(Error_input_special_character, e.class)
                assert_equal("hogeに特殊記号含めんな（/A[a-zA-Z0-9_@]+z/）", e.message)
            end
        end
    end
end




