#!/usr/bin/env ruby

DATADIR = "/tools/acri-olb/vm-host/data/"
LOCK = DATADIR + "LOCK-VBOX"
LOGFILE = DATADIR + "restart-log.txt"

WAIT_LIMIT = 10

def main()
  unless ARGV.size > 0 then
    STDERR.puts("arguments error")
    exit(0)
  end

  vm = ARGV
  mode = nil
  force = dry = false
  if ARGV[0] == '-f'
    mode = "-f (force restart) mode"
    force = true
    vm = ARGV[1..-1]
  elsif ARGV[0] == '-d'
    mode = "-d (dry run) mode"
    dry = true
    vm = ARGV[1..-1]
  end
  
  restarts = ((dry)   ? [] :
              (force) ? vm :
              `#{__dir__}/check-reservation.rb #{vm.join(' ')}`.split(' '))

  log = open(LOGFILE, 'a')
  str = `VBoxManage list runningvms`
  running = str.strip().split("\n").map{|l| d=l.split(" "); d[0][1..-2]}
  
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
end

###########################################################
# main
###########################################################
main()
