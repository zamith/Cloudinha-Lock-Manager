
class MachineController < ApplicationController

  require 'open3'

  def list
    @machines_list_by_type = Machine.all.group_by{|m|m.machine_types_id}
    
    @machines_list_by_type.values.each do |machines|
      machines.each do |machine|
        stdin, stdout, stdin = Open3.popen3('/var/www/ganglia2/nagios/check_heartbeat.sh', "host="+machine[:domain],"threshold=60")
        out = stdout.gets
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
      Foreman.deleteHost(machine.domain)
      res = Foreman.addHost(machine.domain, selected_profile, machine_id, machine.mac)    
      call = "/usr/bin/cawake "+ machine_id
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
