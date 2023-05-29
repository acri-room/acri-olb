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

data/no-restriction.txt にリストアップされたVMは，起動時のログイン制限を行わない．
data/exclusion.txt にリストアップされたVMは，-f オプションがついていない限り再起動の対象としない．
いずれのファイルも，1行に1つのホスト名を記載する．

ログは data/restart-log.txt に保持される

`stopvm.sh`

引数に指定したVMを停止する

`stop-all-vms.sh`

すべてのVMを停止する

`create-vms.rb`

VM を必要な個数だけクローンする
引数は，ホスト名のプレフィクス，クローン元のホスト名，最後のクローン番号
ホスト名は，プレフィクスを vmX，最後のクローン番号を NN とした場合，vmX00, vmX01, vmX02, ..., vmXNN

`check-usb.sh`

管理ユーザの VirtualBox が USB デバイスにアクセス可能かどうか確認し，
もしアクセス不可能な状態になっていればホストを再起動する 