#!/usr/bin/env ruby

LOCK = "/root/acri-olb/vm-host/LOCK-VBOX"

def main()
  unless ARGV.size > 0 then
    puts("arguments error")
    exit(0)
  end
  vm = ARGV

  vm.each{|host|
    open("#{LOCK}-#{host}", 'w'){|lock|
      lock.flock(File::LOCK_EX) # get DB lock
      str = `VBoxManage list runningvms | grep #{host}`
      if str.strip.size == 0
        cmd = "VBoxManage startvm #{host} --type headless"
        puts(cmd)
        system(cmd)
      end
      lock.flock(File::LOCK_UN) # release DB lock
    }
  }
end

###########################################################
# main
###########################################################
main()

