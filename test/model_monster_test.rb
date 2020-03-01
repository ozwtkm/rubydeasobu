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

    socket = "/var/lib/mysql/mysql.sock"
    host = "localhost"
    username = "testwebrick"
    password = "test"
    unixtime= Time.now.to_i
    @tmp_databasename = "UNITTEST_get_master_monsters" + unixtime.to_s
    @tmp_tablename = @tmp_databasename + ".monsters"

    @sql = Mysql2::Client.new(:socket => socket, :host => host, :username => username, :password => password, :encoding => 'utf8')
    @sql.query("create database " + @tmp_databasename)
    
    @sql.query("create table " + @tmp_tablename + "(`name` varchar(20) DEFAULT NULL)") # 本当は他のカラムもちゃんとつける
  end
  
  def teardown()
    super

    @sql.query("drop database " + @tmp_databasename)
    @sql.close
  end

  # result.eachのところは専用の関数にすべき（テストのしやすさ）、とか元々のコードに改善の余地がある気がする
  def test_return_value_not_exist_cache() # 面倒なのでnameだけで検証しているが、本当は他のカラムも含めて検証する
    @sql.query("insert into " + @tmp_tablename + " VALUES ('inoue')")

    Cache.instance.stub(:get, nil) {
      master_monster_list_for_verification = Monster.get_master_monsters().values.map {|monstermodel| monstermodel.name}
      comparison = @sql.query("select * from " + @tmp_tablename).first["name"]

      assert_includes(master_monster_list_for_verification, comparison)
    }
  end


  def test_return_value_exist_cache()
    @sql.query("insert into " + @tmp_tablename + " VALUES ('inoue'), ('りょうやん')")

    Monster.get_master_monsters() #一回叩くと必ずcacheありの状態になる。「一回叩くと必ずcacheありの状態になる」がこの時点では保障されてないけど。。

    master_monster_list_for_verification = Monster.get_master_monsters().values.map {|monstermodel| monstermodel.name}

    comparison1 = @sql.query("select * from " + @tmp_tablename + " where name = 'inoue'").first["name"]
    comparison2 = @sql.query("select * from " + @tmp_tablename + " where name = 'りょうやん'").first["name"]
 
    assert_includes(master_monster_list_for_verification, comparison1)
    assert_includes(master_monster_list_for_verification, comparison2)
  end

end



# totyuu
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