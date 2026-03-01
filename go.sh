#!/bin/ksh
# ./go.sh on live server to compile binaries, move into place, and start

set -A list blast fed mynow nnn

for item in ${list[@]}; do
	cd $item
	go build
	doas mv -f $item /usr/local/bin/
	cd ..
	doas cp rc.d/$item /etc/rc.d/
	doas chmod 0555 /etc/rc.d/$item
	doas rcctl enable $item
	doas rcctl restart $item
done

