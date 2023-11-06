#!/usr/bin/env ruby

SERVER = '172.16.2.5:20080'

require 'net/http'
require 'uri'
require 'json'
require 'time'

TIMESPAN = 3
BASEDIR = "./"
DATADIR = "/tools/acri-olb/vm-host/data/"
LOCK = DATADIR + "LOCK-VBOX"
LOCK_UPDATE = DATADIR + "LOCK-UPDATE"
DATAFILE = DATADIR + "reservation.json"
LOGFILE = DATADIR + "restart-log.txt"
OFFFILE = DATADIR + "no-restriction.txt"
EXCLFILE = DATADIR + "exclusion.txt"

WAIT_LIMIT = 10
$need_migrate = false

def begin_time(hour)
  # return the beginning of the time slot
  h = (hour / TIMESPAN) * TIMESPAN
  return format("%02d:%02d:%02d", h, 0, 0)
end

def check_exclusion(host)
  # check if host is listed on EXCLFILE
  if File.exist?(EXCLFILE)
    File.open(EXCLFILE) do |f|
      while serv = f.gets
        return true if serv.chomp == host || serv.chomp == "*"
      end
    end
  end
  return false
end

def check_reservation(host, log)
  new_json = nil
  open(LOCK_UPDATE, 'w') do |lock|
    lock.flock(File::LOCK_EX) # get DB lock

    # read last data
    old_json = nil
    begin
      infile = File.read(DATAFILE)
      old_json = JSON.parse(infile.strip)
    rescue
      old_json = {'reserve' => {}}
    end

    # check if update is required
    new_json = old_json
    old_time = old_json['time'] && Time.parse(old_json['time'])
    new_time = Time.now
    t = new_time + 300
    slot = begin_time(t.hour)
    $need_migrate = old_time if old_time && old_time.month != new_time.month
    if ! old_time || new_time - old_time > 60
      log.puts "Last data read: #{old_time}"
      log.puts "Current time  : #{new_time}"
      resv = Hash.new

      if SERVER != ''
        # read from reservation server
        url = "http://#{SERVER}/olb-view.cgi"
        url += "?year=#{t.year}"
        url += "&month=#{t.month}"
        url += "&date=#{t.day}"
        url += "&host=#{host[0..-3]}"
        url += "&partial=yes"
        log.puts "read from #{url}"
        log.puts "time slot is #{slot}"

        resv = Net::HTTP.get(URI.parse(url))
        resv = JSON.parse(resv.strip)
      end
      
      # merge resevation info and save to file
      new_json = {'time' => new_time.to_s, 'reserve' => {}}
      old_json['reserve'].each do |serv, users|
        new_json['reserve'][serv] = {} if ! new_json['reserve'][serv]
        new_json['reserve'][serv]['old'] = users['new']
      end
      resv.each do |serv, users|
        new_json['reserve'][serv] = {} if ! new_json['reserve'][serv]
        new_json['reserve'][serv]['new'] = users[slot]
      end

      # turn off restriction for servers listed on OFFFILE
      if File.exist?(OFFFILE)
        off_list = Array.new
        File.open(OFFFILE) do |f|
          while serv = f.gets
            serv.chomp!
            new_json['reserve'][serv] = {} if ! new_json['reserve'][serv]
            new_json['reserve'][serv]['new'] = 'everyone'
            off_list << serv
          end
        end
        if ! off_list.empty?
          log.puts "Login restriction is turned off in the following server(s):"
          log.puts "  " + off_list.join(' ')
        end
      end
      File.open(DATAFILE, 'w'){|f| f.puts(JSON.generate(new_json)) }
    end

    lock.flock(File::LOCK_UN) # release DB lock
  end
  return new_json['reserve'][host]
end

def check_user_diff(host, log)
  user = check_reservation(host, log)
  if ! user
    log.puts "#{host} has not been reserved"
    return false
  else
    log.puts "#{host} was reserved by #{user['old']}" if   user['old']
    log.puts "#{host} was not reserved"               if ! user['old']
    log.puts "#{host} is reserved by #{user['new']}"  if   user['new']
    log.puts "#{host} is not reserved"                if ! user['new']
    return (user['old'] != user['new'])
  end
end

def main()
  unless ARGV.size > 0 then
    STDERR.puts("arguments error")
    exit(0)
  end

  log = open(LOGFILE, 'a')

  vm = ARGV
  force = dry = false
  if ARGV[0] == '-f'
    log.puts "-f (force restart) mode is enabled"
    force = true
    vm = ARGV[1..-1]
  elsif ARGV[0] == '-d'
    log.puts "-d (dry run) mode is enabled"
    dry = true
    vm = ARGV[1..-1]
  end
  
  restarts = []
  str = `VBoxManage list runningvms`
  running = str.strip().split("\n").map{|l| d=l.split(" "); d[0][1..-2]}
  
  if ! force
    vm.each{|host|
      excl = check_exclusion(host)
      flag = check_user_diff(host, log)
      if excl
        log.puts "#{host} is listed for exclusion"
      elsif flag
        log.puts "#{host} has to be restarted"
        restarts << host
      elsif ! running.include?(host)
        log.puts "#{host} is not started yet"
        restarts << host
      end
    }
  else
    restarts = vm
  end
  log.puts "restart: #{restarts}"
  restarts = [] if dry

  restarts.each{|host|
    open("#{LOCK}-#{host}", 'w'){|lock|
      lock.flock(File::LOCK_EX) # get DB lock

      if running.include?(host)
        system("VBoxManage controlvm #{host} acpipowerbutton")
        str = `VBoxManage list runningvms | grep #{host}`
        n = 0
        while(str.strip.size > 0)
          system("VBoxManage controlvm #{host} poweroff") if(n == WAIT_LIMIT)
          n += 1 if n < (WAIT_LIMIT + 1)
          log.puts("wait for stop #{host} (#{n})")
          sleep 5
          str = `VBoxManage list runningvms | grep #{host}`
        end
      end
      cmd = "VBoxManage startvm #{host} --type headless"
      log.puts(cmd)
      system(cmd)

      lock.flock(File::LOCK_UN) # release DB lock
    }
  }
  log.puts "restart-vm finished at #{Time.now}"
  log.puts ""
  log.close
  File.rename(LOGFILE, LOGFILE + '.' + $need_migrate.strftime("%Y%m")) if $need_migrate
end

###########################################################
# main
###########################################################
main()
