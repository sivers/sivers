for i in /var/www/tmp/*.pid
do echo "$i stopping"
	kill `cat $i`
done
