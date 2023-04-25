#!/usr/bin/env ruby

LOCK = "/tools/acri-olb/vm-host/data/LOCK-VBOX"

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
        ret = `#{cmd} | grep "error"`
        p ret
        str = `VBoxManage list runningvms | grep #{host}`
        p str
        if str.strip.size == 0
          sleep(1)
          str = `VBoxManage list runningvms | grep #{host}`
          if str.strip.size == 0
            puts("Failure to start #{host}")
            system("VBoxManage startvm #{host} --type emergencystop")
            system("VBoxManage startvm #{host} --type headless")
            str = `VBoxManage list runningvms | grep #{host}`
            p str
          end
        end
      end
      lock.flock(File::LOCK_UN) # release DB lock
    }
  }
end

###########################################################
# main
###########################################################
main()

