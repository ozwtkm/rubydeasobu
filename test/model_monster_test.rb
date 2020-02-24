require 'minitest/autorun'
require 'securerandom'
require 'pry'
require 'pp'

require_relative '../model/monster' 
require_relative '../_util/environment'
require_relative '../_util/sqltool'
require_relative '../server' # もろもろrequireしてくれる

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

class Get_master_monstersTest < Base_unittest
  def setup()
    super
  end
  
  def teardown()
    super
  end

  # cacheから取るときとselectする時がある、result.eachのところは専用の関数にすべき（テストのしやすさ）、
  # 謎：テストしたい関数から呼んでる別の関数は全てstub化するべき？
  # テストすべき観点のせんびき、枝切りの温度感がわからない
  def test_return_value() # 帰ってくるリストはちゃんとしたリストモンスターリストなのか　（そもそもテストすべき項目？
    master_monster_list_for_verification = Monster.get_master_monsters()
    comparison = SQL.master("select * from monsters")

    master_monster_list_for_verification.each do |monsterid, monstermodel|
      assert_equal(monstermodel.atk, comparison.select{|x| x["id"]===monsterid}[0]["atk"])
      # defとかは同様なので略
    end
  end
end




class Get_specific_monsterTest < Base_unittest
  SAMPLE_MONSTER_ID = 5

  def setup()
    super
  end
  
  def teardown()
    super
  end

  def test_not_exist_id
    Monster.stub(:get_master_monsters, {SAMPLE_MONSTER_ID => nil}) do 
      assert_raises() {
        Monster.get_specific_monster(SAMPLE_MONSTER_ID)
      }
    end
  end
end