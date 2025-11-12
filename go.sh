#!/bin/ksh
# ./go.sh on live server to compile binaries, move into place, and start

# usually the directory name is same as the Go filename
# but when different, use dirname/base-filename
set -A list nnn mynow scripts/listener

for item in ${list[@]}; do
	if [[ $item == */* ]]; then
		d=${item%/*}
		f=${item#*/}
	else
		d=$item
		f=$item
	fi
	cd $d
	go build $f.go
	doas mv -f $f /usr/local/bin/
	cd ..
	doas cp rc.d/$f /etc/rc.d/
	doas chmod 0555 /etc/rc.d/$f
	doas rcctl enable $f
	doas rcctl restart $f
end
