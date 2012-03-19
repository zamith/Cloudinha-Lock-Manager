require 'patron'

module Foreman_Api

  def self.deleteHost(hostname)
    sess = Patron::Session.new
    sess.timeout = 10
    sess.base_url = "http://foreman.lsd.com/hosts/"
    res = sess.delete(hostname, {"Accept" => "application/json"})
    if not res.status_line.include? "HTTP/1.1 200 OK"
      return "error"
    end
  end

  def self.addHost(hostname, hostgroup, id, mac)
    sess = Patron::Session.new
    sess.base_url = "http://foreman.lsd.com"
    if hostname.match(/^([^\.]*)\..*/) 
      hostname_name = $1
      id = 200 + Integer(id)
      ip = "192.168.111."+id.to_s

      param_hash = Hash.new
      param_hash["host[name]"] = hostname_name
      param_hash["host[hostgroup_id]"] = hostgroup
      param_hash["host[ip]"] = ip
      param_hash["host[build]"] = 1
      param_hash["host[mac]"] = mac

      res = sess.post("/hosts", param_hash  ,{"Accept" => "application/json"})
      
      if not res.status_line.include? "HTTP/1.1 201 Created"
        return res.body
      else
        return "sucess"
      end
    else 
      return "error"
    end 
  end
end

class MachineController < ApplicationController

  require 'open3'

  def list
    @machines = Machine.all
    @machines.each do |machine|
      stdin, stdout, stdin = Open3.popen3('/var/www/ganglia2/nagios/check_heartbeat.sh', "host="+machine[:domain],"threshold=60")
      out = stdout.gets
      if out.nil?
        machine[:status] = 'Unknown'
      else
        if out.match(/.*(\d\d):(\d\d)$/)
          if $1 == "00" && $2.to_i <= 30 
            machine[:status] = 'Alive'
          else
            machine[:status] = 'Dead'
          end
        else
          machine[:status] = 'Dead'
        end
      end
     end
  end
	
  def format
    @machines = Machine.all
    @options = Foreman.getHostgroups
  end
  
  def mformat
    machines = Array.new
    if params.has_key? :machine  
      machines << params[:machine]
    elsif params.has_key? :from and params.has_key? :to
      params[:from].upto(params[:to]){ |machine_num| 
        machines << machine_num
      }
    end
   
    selected_profile = params[:host_group] 
    
    machines.each{ |machine_id|

      machine = Machine.find machine_id
      Foreman_Api.deleteHost(machine.domain)
      res = Foreman_Api.addHost(machine.domain, selected_profile, machine_id, machine.mac)    
      call = "/usr/bin/cawake "+ machine
      system call
      call = "ssh root@192.168.111."+(200+Integer(machine_id)).to_s+" reboot"
      system call

    }
  
    redirect_to root_path
    
  end


#  def show 
#    render :action => 'list'
#  end

  def awake
    call = "/usr/bin/cawake "+params[:id]
    system call
    redirect_to root_path
  end 

  def mawake
    call = "/usr/bin/cawake -t 10 "+params[:from]+"-"+params[:to]
    system call
    redirect_to root_path
  end

  def shutdown
    call = "/usr/bin/cshutdown "+params[:id]
    system call
    redirect_to root_path
  end

  def mshutdown
    call = "/usr/bin/cshutdown "+params[:from]+"-"+params[:to]
    system call
    redirect_to root_path
  end

  def lock    
    already_locked = Machine.lock params[:from], params[:to], params[:name]

    respond_to do |format|
      format.html {redirect_to root_path}
      format.json {render :json => {'locked'=>already_locked.to_json}}
    end
  end

  def unlock
    Machine.unlock params[:from], params[:to]

    respond_to do |format|
      format.html {redirect_to root_path}
      format.json {render :json => {'ok'=>"true"}}
    end
  end

end
