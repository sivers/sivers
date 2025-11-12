#!/bin/ksh
# sh go.sh on live server to compile binaries, move into place, and start

cd nnn
go build
doas mv -f nnn /usr/local/bin/
cd ..

cd mynow
go build
doas mv -f mynow /usr/local/bin/
cd ..

cd scripts
go build listener.go
doas mv -f listener /usr/local/bin/
cd ..

for s in nnn mynow listener; do
	doas cp rc.d/$s /etc/rc.d/
	doas chmod 0555 /etc/rc.d/$s
	doas rcctl enable $s
	doas rcctl restart $s
done
