require 'yaml'
require 'patron'

class Foreman

  foreman_config = YAML.load_file "#{RAILS_ROOT}/config/foreman.yml"

  @@foreman_url = ''
  @@foreman_ip_range = ''
  if foreman_config['foreman_url']
    @@foreman_url = foreman_config['foreman_url']
  end
  if foreman_config['foreman_ip_range']
    @@foreman_ip_range = foreman_config['foreman_ip_range']
  end

  def self.getHostgroups
    begin

      foreman_db_config = YAML.load_file "#{RAILS_ROOT}/config/foreman.yml"

      if not foreman_db_config['foreman']
        Rails.logger.info "No configuration present for foreman database"
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
      Rails.logger.info "Mysql error on hostgroup retrieval: #{e.error}"
      return []
    ensure
      mysql_db.close if mysql_db
    end
  end

  def self.deleteHost(hostname)

    if @@foreman_url ==''
      Rails.logger.info "Error on host deletion, foreman url is not defined"
    end

    sess = Patron::Session.new
    sess.timeout = 10
    sess.base_url = @@foreman_url.to_s()+"/hosts/"
    res = sess.delete(hostname, {"Accept" => "application/json"})
    if not res.status_line.include? "HTTP/1.1 200 OK"
      Rails.logger.info "Error on host deletion:" + res.status_line
    else
      Rails.logger.info "Host deleted: " + res.status_line
    end

  end

  def self.addHost(hostname, hostgroup, id, mac)
    sess = Patron::Session.new
    if @@foreman_ip_range ==''
      Rails.logger.info "Error on host creation, ip rage is not defined"
    end

    sess.base_url = @@foreman_url.to_s
    if hostname.match(/^([^\.]*)\..*/)
      hostname_name = $1
      id = 200 + Integer(id)
      ip = @@foreman_ip_range.to_s()+"."+id.to_s

      param_hash = Hash.new
      param_hash["host[name]"] = hostname_name
      param_hash["host[hostgroup_id]"] = hostgroup
      param_hash["host[ip]"] = ip
      param_hash["host[build]"] = 1
      param_hash["host[mac]"] = mac

      res = sess.post("/hosts", param_hash  ,{"Accept" => "application/json"})

      if not res.status_line.include? "HTTP/1.1 201 Created"
        Rails.logger.info "Error on host creation:" + res.status_line
	Rails.logger.info res.body
      else
        Rails.logger.info "Host created: " + res.status_line
      end
    else
      Rails.logger.info "Error on host creation, bad hostname: " + hostname
    end
  end


end
