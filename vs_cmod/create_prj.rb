require './vivado_util.rb'

def main(key)
  dir="prj_#{key}"
  name="top_#{key}"
  board_id="4'h#{key}"
  
  vivado = Vivado.new(dir=dir, name=name, top="top")
  #vivado.add_parameters({"general.maxThreads" => 1})
  
  vivado.set_target("xc7a35tcpg236-1")
  vivado.add_sources(["sources/top.v"])
  vivado.add_constraints(["sources/top.xdc"])
  vivado.add_testbenchs([])
  vivado.add_ipcores(["ipcores/ila_0.xci"])
  
  vivado.add_verilog_define({"BOARD_ID" => board_id})
  
  #vivado.generate_tcl("create_prj.tcl")
  vivado.run()
  
  config = Vivado.new(dir=dir, name=name, top="top", kind=Vivado.CONFIG)
  config.set_chip("xc7a35t_0")
  config.generate_tcl("config_board_#{key}.tcl")
  config.run()
end

first = ARGV[0].to_i || 0
last  = ARGV[1].to_i || 9

first.upto(last){|n|
  key = format("%X", n+1)
  main(key)
}
