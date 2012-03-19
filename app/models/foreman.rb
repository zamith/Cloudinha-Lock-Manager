require 'yaml'

class Foreman 

  def self.getHostgroups 
  
    begin

      foreman_db_config = YAML.load_file "#{RAILS_ROOT}/config/foreman.yml"
      
      if foreman_db_config['foreman']
        File.open("/tmp/teste_config_file", 'w') {|f| f.write(foreman_db_config['foreman']) }
      else
        return []   
      end

      database_config = foreman_db_config['foreman']

      if not database_config['port']
        database_config['port'] = 3306
      end
      if not database_config['socket']
        database_config['socket'] = "/var/run/mysqld/mysqld.sock"
      end

      mysql_db = Mysql::new(database_config['hostname'], database_config['username'],  database_config['password'],
                            database_config['database'], database_config['port'] , database_config['socket'])    
      
      statement = mysql_db.prepare "select id,name from hostgroups"
      res = statement.execute 
      
      host_groups = Hash.new
      
      while row = statement.fetch do
        value =  row[0].to_s+"-"+row[1].to_s.gsub(/(\s)/,'-').downcase
        host_groups[row[1]] = value
      end
      
      return host_groups
      
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
    ensure
      mysql_db.close if mysql_db  
      return []                                                                                     
    end
  end 
  
end