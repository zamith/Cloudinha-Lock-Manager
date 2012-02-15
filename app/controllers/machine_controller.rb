class MachineController < ApplicationController

  require 'open3'

  def list
    @machines = Machine.all
    @machines.each do |machine|
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

#  def show 
#    render :action => 'list'
#  end

  def awake
    call = "/usr/bin/cawake "+params[:id]
    puts call
    system call
    redirect_to root_path
  end 

  def mawake
    call = "/usr/bin/cawake -t 10 "+params[:from]+"-"+params[:to]
    puts call
    system call
    redirect_to root_path
  end

  def shutdown
    call = "/usr/bin/cshutdown "+params[:id]
    puts call
    system call
    redirect_to root_path
  end

  def mshutdown
    call = "/usr/bin/cshutdown "+params[:from]+"-"+params[:to]
    puts call
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
