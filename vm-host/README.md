## Setup

crontab に以下のスクリプトを登録する
*/2 * * * * /tools/acri-olb/vm-host/restart-vm.rb LIST_OF_VMS

## Description

`start-vm.rb`

start all VMs

`restart-vm.rb`

引数に指定したVMを再起動する（ただし予約状況に変化がある場合のみ）

オプション -f を先頭につけると強制的に再起動する．
オプション -d を先頭につけると予約状況のチェックのみ行う．

ログは data/restart-log.txt に保持される

`stopvm.sh`

引数に指定したVMを停止する

`stop-all-vms.sh`

すべてのVMを停止する

