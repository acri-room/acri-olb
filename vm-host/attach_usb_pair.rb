
list = `VBoxManage list usbhost`

vms = ['vsA01', 'vsA02', 'vsA03', 'vsA04', 'vsA05', 'vsA06', 'vsA07', 'vsA08', 'vsA09']
fpgas = {}
uarts = {}

device = {}
list.split("\n").each{|l|
	if /^UUID:/ =~ l then
		device['uuid'] = l.split(/\s+/)[1]
		#puts(l)
	elsif /^Product:/ =~ l then
		device['product'] = l.split(/\s+/)[1]
		#puts(l)
	elsif /^Address:/ =~ l then
		device['address'] = l.split(/\s+/)[1]
		device['parent'] = l.split(/\s+/)[1].split(":")[4].split(/\/+/)[0..-3].join("/")
		#puts(l)
		#puts(device)
		if device['product'] == 'USB-Blaster'
			fpgas[device['parent']] = device
		end
		if device['product'] == 'FT230X'
			uarts[device['parent']] = device
		end
		device = {}
		device['product'] = 'XXX'
	end
}
#fpgas.each{|k,v| p v}
#uarts.each{|k,v| p v}
pairs = []
fpgas.each{|k,v|
	uart = uarts[k]
	puts("# #{v['uuid']}, #{v['product']}, #{v['address']}")
	puts("# #{uart['uuid']}, #{uart['product']}     , #{uart['address']}")
	pairs << [v['uuid'], uart['uuid']]
}

pairs.each_with_index{|pair, i|
	puts("VBoxManage controlvm #{vms[i]} usbattach #{pair[0]}")
	puts("VBoxManage controlvm #{vms[i]} usbattach #{pair[1]}")
	system("VBoxManage controlvm #{vms[i]} usbattach #{pair[0]}")
	system("VBoxManage controlvm #{vms[i]} usbattach #{pair[1]}")
}

