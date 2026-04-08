#!/bin/sh
# by Derek Sivers
# Updated: 2025-06-09 with radicale and dovecot for OpenBSD 7.7
# INSTALL: cd /root ; ftp https://sive.rs/ti.sh ; sh ti.sh
# README: https://sive.rs/ti

if [[ $(id -u) -ne 0 || $(uname) != "OpenBSD" ]]; then
    echo "must be run as root on OpenBSD 7.7 at Vultr.com"
    exit 1
fi


# tiny files where your answers are saved, so you can run this again and not answer again
# to add another user, do `rm /root/my/user*` then run this script again
mkdir -p /root/my
function my {
	echo "/root/my/$1"
}


# INITIAL SETUP
if [ ! -f /usr/local/bin/curl ]; then
	echo "updating..."
	syspatch
	# disable IPv6 and sound
	rcctl disable slaacd sndiod
	# shorten motd for future logins
	cat /etc/motd | head -3 | grep -v '^$' > /tmp/motd
	mv /tmp/motd /etc/motd
	# install needed software
	pkg_add curl rsync--minimal radicale-2.1.12p8 links mutt--sasl dovecot-2.3.21.1p1v0
fi
# download config files
set -A a pf.conf httpd.conf relayd.conf acme-client.conf .muttrc .mailcap smtpd.conf dovecot.conf rander.pl hello.txt hello.pdf derek.jpg guitar.mp3 ymap.mp4
for x in "${a[@]}"; do
	if [ ! -f $x ]; then
		ftp https://sive.rs/file/$x
	fi
done
if [ -f pf.conf ]; then
	mv pf.conf /etc/pf.conf
	pfctl -f /etc/pf.conf
fi


# DOMAIN?
if [ -f $(my domain) ]; then
	domain=$(cat $(my domain))
else
	printf "Your domain name? "
	read ui
	# strip whitespace, convert to lowercase, and remove 'www.' prefix
	domain=$(echo "$ui" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | sed 's/^www\.//')
	# save to a file for next time
	echo $domain > $(my domain)
fi


# USERNAME?
if [ -f $(my user) ]; then
	user=$(cat $(my user))
else
	printf "Your user name? (one lowercase word, no spaces): "
	read ui
	# strip whitespace, convert to lowercase, and remove all but a-z and 0-9
	user=$(echo "$ui" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
	# save to a file for next time
	echo $user > $(my user)
fi


# DOMAIN AND USER OK?
if [ ! -f $(my userok) ]; then
	echo "Email and login will be $user@$domain"
	printf "Does that look right? (y/n) "
	read ui
	# strip whitespace, convert to lowercase, get just first letter
	yn=$(echo "$ui" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | cut -c1-1)
	if [ $yn == "y" ]; then
		# touch file for next time
		touch $(my userok)
	else
		rm $(my domain) $(my user)
		echo "Please run this script again."
		exit 1
	fi
fi


# FULL NAME?
if [ -f $(my userfullname) ]; then
	name=$(cat $(my userfullname))
else
	printf "Your full name? "
	read name
	# save to a file for next time
	echo "$name" > $(my userfullname)
fi


# IP ADDRESS?
if [ -f $(my ip) ]; then
	ip=$(cat $(my ip))
else
	ip=$(ifconfig vio0 | grep inet | awk '/inet/ {print $2}')
	# alternate: curl -s icanhazip.com
	# save to a file for next time
	echo $ip > $(my ip)
fi
echo "IP address is $ip"


# ADD USER
if [[ ! -d /home/$user ]]; then
	echo "Create a secret password for $user, for login and email:"
	groupadd $user
	useradd -b /home -g $user -k /etc/skel -L staff -s /bin/ksh -d /home/$user -m -c "$name" $user
	passwd $user
	cat /root/.ssh/authorized_keys >> /home/$user/.ssh/authorized_keys
	echo "permit nopass $user" >> /etc/doas.conf
	printf "\n\n#############################\n"
	echo "TEST #1: LOG IN"
	echo "Open a NEW terminal window on your computer, and type this:"
	echo "ssh $user@$ip"
	echo ""
	echo "It should say 'OpenBSD 7.7 (GENERIC.MP)' and 'Welcome to OpenBSD'."
	echo "After that works, come back to this terminal window."
	printf "I'll wait"
	loggedin=""
	while [[ $loggedin == "" ]]; do
		printf "."
		sleep 3
		loggedin=$(w|grep ^$user)
	done
	echo "YOU DID IT!  Logging out that user now, because it's time for..."
	# find new user's SSH session and kill it to log them out
	pid=$(ps aux|grep sshd|grep ^$user|tail -1|awk '{print $2}')
	kill -HUP $pid
	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
	rcctl restart sshd
	printf "\n\n#############################\n"
	echo "TEST #2: LOG IN WITHOUT A PASSWORD"
	echo "Because I just disabled passwords, for super-security, make sure you can"
	echo "log in with your SSH public key."
	echo "Back in that other terminal window on your computer, login again like this:"
	echo "ssh $user@$ip"
	echo ""
	echo "Again, it should say 'OpenBSD 7.7 (GENERIC.MP)' and 'Welcome to OpenBSD'."
	echo ""
	# if trouble:
	#   sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
	#   rcctl restart sshd
	echo "If it doesn't work, hit Ctrl-C here and use root user to copy the contents"
	echo "of your SSH public key (id_ed25519.pub) into /home/$user/.ssh/authorized_keys"
	printf "Waiting"
	loggedin=""
	while [[ $loggedin == "" ]]; do
		printf "."
		sleep 3
		loggedin=$(w|grep ^$user)
	done
	echo "YOU DID IT!  Logging out that user again."
	# find new user's SSH session and kill it to log them out
	pid=$(ps aux|grep sshd|grep ^$user|tail -1|awk '{print $2}')
	kill -HUP $pid
	# SECURE LOGIN
	sed -i "s/RootLogin yes/RootLogin no/g" /etc/ssh/sshd_config
	rcctl restart sshd
	echo "I have disabled the root user, for security, so NEVER LOG IN AS 'root' AGAIN."
	echo "Only log in as $user from now on."
	echo "To run a super-user (root) command, just type 'doas' before it."
fi


# VULTR API KEY?
# file contains their previous answer
if [ -f $(my vultr) ]; then
	vultrapi=$(cat $(my vultr))
else
	printf "\n\n#############################\n"
	echo "YOU NEED TO DO THIS NOW:"
	echo "1. Log in to your account at vultr.com"
	echo ""
	echo "2. Go to https://my.vultr.com/settings/#settingsapi"
	echo "(Or to get there: on the far left, click 'Account'"
	echo "then to the right of it, click 'API' 3rd from bottom.)"
	echo ""
	echo "3. Under 'Access Control', under 'Enter your IPv4', add this:"
	echo "$ip  /  32"
	echo "... then click the [Add] button"
	echo ""
	printf "4. Under 'Personal Access Token', copy your API key and paste it here: "
	# Repeat until correct API and Access Control
	apiok=""
	while [[ $apiok != "200" ]]; do
		read ui
		# strip whitespace
		vultrapi=$(echo "$ui" | tr -d '[:space:]')
		# if API key works, gets "200" HTTP response code
		apiok=$(curl -o /dev/null -s -w '%{http_code}' "https://api.vultr.com/v2/domains" -X GET -H "Authorization: Bearer $vultrapi")
		if [[ $apiok == "200" ]]; then
			echo "API works!"
			# save to a file for next time
			echo $vultrapi > $(my vultr)
			# ADD DOMAIN NOW
			domainadded=$(curl -o /dev/null -s -w '%{http_code}' "https://api.vultr.com/v2/domains/$domain" -X GET -H "Authorization: Bearer $vultrapi")
			# if domain is in DNS already, the API returns "200" HTTP response code
			if [[ $domainadded == "200" ]]; then
				echo "$domain is in Vultr DNS already."
				echo "Assuming this is from a previous installation, I'll delete the previous entries now and start fresh, OK?"
				echo "Hit [enter] if this is OK, or hit Ctrl-C now to stop and re-start the script."
				read ui
				res=$(curl -s "https://api.vultr.com/v2/domains/$domain" -X DELETE -H "Authorization: Bearer $vultrapi")
			fi
			echo "Adding $domain to Vultr DNS. A, CNAME, and MX to $ip."
			res=$(curl -s "https://api.vultr.com/v2/domains" -X POST -H "Authorization: Bearer $vultrapi" -H "Content-Type: application/json" --data "{\"domain\":\"$domain\", \"ip\":\"$ip\"}")
		else
			echo "Sorry. It's not authorizing. See steps 3 and 4, above."
			echo "Under 'Access Control', make sure it says $ip/32"
			printf "And copy+paste your long API key here: "
		fi
	done
fi


# WHICH INSTANCE ID? ("instance" is Vultr's name for this server)
if [ -f $(my instance) ]; then
	instance=$(cat $(my instance))
else
	# JSON, so put each { on new line, grep for line with this IP address, then awk to extract "id":"id-is-here"
	instance=$(curl -s "https://api.vultr.com/v2/instances" -X GET -H "Authorization: Bearer $vultrapi" | perl -pe 's/{/\n{/g' | grep $ip | awk -F'"id":"|"' '/"id":"/ {print $2}')
	echo "Saving your server ID ($instance), and adding reverse DNS."
	echo $instance > $(my instance)
	# SET REVERSE DNS:  ($ip = $domain)
	res=$(curl -s "https://api.vultr.com/v2/instances/$instance/ipv4/reverse" -X POST -H "Authorization: Bearer $vultrapi" -H "Content-Type: application/json" --data "{\"ip\":\"$ip\", \"reverse\":\"$domain\"}")
fi


# STORAGE:
if [ ! -f $(my storageno) ]; then
	# check each time in case they added new storage
	sd1=$(disklabel sd1 2>&1)
	if [[ $sd1 == *"Device not configured"* ]]; then
		echo "You do not have 'Block Storage' attached to this server."
		printf "Do you want encrypted file storage? (y/n) "
		read ui
		yn=$(echo "$ui" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | cut -c1-1)
		if [ $yn == "n" ]; then
			touch $(my storageno)
		else
			# Find unattached block: (separate JSON, grep for empty instance, awk to get ID)
			bid=$(curl -s "https://api.vultr.com/v2/blocks" -X GET -H "Authorization: Bearer $vultrapi" | perl -pe 's/{/\n{/g' | grep '"attached_to_instance":""' | head -1 | awk -F'"id":"|"' '/"id":"/ {print $2}')
			if [[ $bid == "" ]]; then
				echo "You don't have any available Block Storage. See https://sive.rs/ti"
				echo "Deploy Block Storage at https://my.vultr.com/blockstorage/ then run this script again."
				exit 1
			else
				# echo "Block ID $bid. Instance ID $instance. You don't need this info."
				res=$(curl -s "https://api.vultr.com/v2/blocks/$bid/attach" -X POST -H "Authorization: Bearer $vultrapi" -H "Content-Type: application/json" --data "{\"instance_id\":\"$instance\", \"live\":true}")
				# Prompt then reboot
				printf "\n\n#############################\n"
				echo "COME BACK TO CONTINUE:"
				echo "Storage attached, but now it needs to reboot, since it looks for storage at boot time."
				echo "After it reboots, wait a minute then type this to continue:"
				echo "ssh $user@$ip"
				echo "doas su"
				echo "cd"
				echo "sh ti.sh"
				echo "# OK? Hit [enter] now to let it reboot."
				read ui
				touch $(my rebooted)
				reboot
				exit 0
			fi
		fi
	elif [[ $sd1 == *"duid: 0000000000000"* ]]; then
		echo 'RAID *' | disklabel -wAT- sd1
		echo "Make a password for your encrypted storage:"
		bioctl -c C -l sd1a softraid0
		echo '/ *' | disklabel -wAT- sd2
		newfs sd2a
		mount /dev/sd2a /mnt
		chown -R $user:$user /mnt
		chmod 770 /mnt
	fi
fi


# TEST STORAGE
if [[ ! -f $(my storageno) && ! -f $(my storageok) ]]; then
	echo '#!/bin/sh\ndoas bioctl -c C -l sd1a softraid0\ndoas mount /dev/sd2a /mnt\nls -l /mnt' > /usr/local/sbin/m
	echo '#!/bin/sh\ndoas umount /mnt\ndoas bioctl -d sd2\necho "unmounted"' > /usr/local/sbin/m-x
	chmod 755 /usr/local/sbin/m /usr/local/sbin/m-x
	echo "Testing that your encrypted storage works."
	# if not mounted already, mount it
	res=$(df|grep '/mnt$')
	if [[ $res == "" ]]; then
		echo "Your encrypted storage password:"
		bioctl -c C -l sd1a softraid0
		mount /dev/sd2a /mnt
		chown -R $user:$user /mnt
	fi
	uploaded=$(ls /mnt)
	if [[ $uploaded != "" ]]; then
		echo "You've already uploaded to /mnt so we're good."
	else
		printf "\n\n#############################\n"
		echo "Back on the Tech Independence web page: https://sive.rs/ti"
		echo "Put $domain and $user into CUSTOMIZE THESE INSTRUCTIONS."
		echo "Then see the section called USE YOUR ENCRYPTED STORAGE."
		echo "Use rsync or FreeFileSync (or scp or sftp or WinSCP) to upload."
		printf "Now upload anything to $user@$ip:/mnt/ while I wait"
		while [[ $uploaded == "" ]]; do
			printf "."
			sleep 3
			uploaded=$(ls /mnt)
		done
		echo "YOU DID IT!"
	fi
	# echo "Unmounting encrypted storage now."
	# umount /mnt
	# bioctl -d sd2
	touch $(my storageok)
fi

if [ ! -f $(my rebooted) ]; then
	echo "Your server needs to reboot now, to apply the initial syspatch."
	echo "AFTER IT REBOOTS, TYPE THIS FROM YOUR TERMINAL TO LOG IN AGAIN:"
	echo "ssh $user@$ip"
	echo ""
	echo "AFTER LOGGING IN, TYPE:"
	echo "doas su"
	echo "cd"
	echo "sh ti.sh"
	echo ""
	echo "... so we can continue, OK?  Hit [enter] now to reboot."
	read ui
	touch $(my rebooted)
	reboot
	exit 0
fi

## STUFF AFTER THIS NEEDS DNS / DOMAIN RESOLVING, so....

# NAMESERVERS HERE?
ns=$(nslookup -type=NS $domain)
if [[ $ns == *ns1.vultr.com* && $ns == *ns2.vultr.com* ]]; then
	echo "$domain nameservers are set to vultr.com."
elif [[ $ns == *SERVFAIL* ]]; then
	echo "$domain nslookup returning mysterious 'SERVFAIL'"
	echo "Next steps might or might not work! If not, try again later."
else
	printf "\n\n#############################\n"
	echo "YOU NEED TO DO THIS NOW:"
	echo "1. Log in to the website where you registered your $domain domain name."
	echo "(Example: godaddy.com namecheap.com porkbun.com bookmyname.com)"
	echo ""
	echo "2. Edit the DNS Name Servers (NS)"
	echo "They are currently set to:"
	echo "$ns" | awk -F'nameserver = ' '/nameserver = / {print $2}' | grep -v '^$'
	echo ""
	echo "3. Erase those and replace them with:"
	echo "ns1.vultr.com"
	echo "ns2.vultr.com"
	echo ""
	echo "4. Wait a while (1-24 hours) and run this script again."
	exit 0
fi

# create cert-renew script if not there already
if [ ! -f /usr/local/sbin/cert-renew ]; then
	echo "#!/bin/sh\nacme-client $domain\nrcctl restart relayd\nrcctl restart dovecot" > /usr/local/sbin/cert-renew
	chmod 700 /usr/local/sbin/cert-renew
fi
# add cert-renew to crontab if not there already
res=$(crontab -l|grep cert-renew)
if [[ $res == "" ]]; then
	(crontab -l 2>/dev/null; echo "11\t3\t*\t*\t5\t/usr/local/sbin/cert-renew") | crontab - 
fi


# WEB
if [ ! -f $(my webok) ]; then
	echo "Setting up https://$domain/ web server and secure certificate."
	sed -i s/example.com/$domain/g httpd.conf relayd.conf acme-client.conf
	cp httpd.conf relayd.conf acme-client.conf /etc/
	rcctl enable httpd
	rcctl start httpd
	acme-client -v $domain
	rcctl enable relayd
	rcctl start relayd
	html=$(printf '<!doctype html>\n<title>%s</title>\n<h1>%s</h1>\n<p>%s<br>\n<a href="mailto:%s@%s">%s@%s</a>\n</p>\n<p>Test <a href="/pub/">public files</a></p>' $domain $domain "$name" $user $domain $user $domain)
	echo $html > /var/www/htdocs/index.html
	rm -rf /var/www/htdocs/bgplg
	mkdir -p /var/www/htdocs/pub
	mv hello.txt hello.pdf derek.jpg guitar.mp3 ymap.mp4 /var/www/htdocs/pub/
	chown -R $user:$user /var/www/htdocs
	printf "\n\n#############################\n"
	echo "TEST THIS NOW:"
	echo "Go to https://$domain/ now to verify the index.html placeholder."
	echo "It should say $domain with your name and $user@$domain."
	echo "Hit [enter] here if it's good, or Ctrl-C to quit and try again."
	read ui
	touch $(my webok)
fi


# EMAIL SERVER SETUP
# if conf files are here, email hasn't been set up yet
if [ -f smtpd.conf ]; then
	sed -i s/example.com/$domain/g smtpd.conf
	mv smtpd.conf /etc/mail/
	touch /etc/mail/secrets
	rcctl restart smtpd
fi
if [ -f dovecot.conf ]; then
	sed -i s/example.com/$domain/g dovecot.conf
	rm -rf /etc/dovecot/*
	mv dovecot.conf /etc/dovecot/
	rcctl enable dovecot
	rcctl start dovecot
fi

# SMTP USERNAME & PASSWORD
# Strange to put this here, but need to update /root/.muttrc with it now,
# even though they haven't signed up to smtp2go.com yet, because they have
# to receive email (with mutt) to sign up for smtp2go.com
# (All users use same SMTP2GO username & password for sending.)
# 
# Generate random username and password using custom-made "rander.pl" script
# The first line (head -1) is username and last line (tail -1) is password.
if [ -f $(my smtpuser) ]; then
	smtpuser=$(cat $(my smtpuser))
else
	# make random SMTP username for SMTP2GO
	smtpuser=$(perl rander.pl|head -1)
	# save to a file for next time
	echo $smtpuser > $(my smtpuser)
fi

if [ -f $(my smtppass) ]; then
	smtppass=$(cat $(my smtppass))
else
	# make random SMTP password for SMTP2GO
	smtppass=$(perl rander.pl|tail -1)
	# save to a file for next time
	echo $smtppass > $(my smtppass)
fi

echo "smtp2go $smtpuser:$smtppass" > /etc/mail/secrets
chmod 640 /etc/mail/secrets
chown root:_smtpd /etc/mail/secrets
rcctl restart smtpd
sed -i "s/SMTPUSER/$smtpuser/g" .muttrc
sed -i "s/SMTPPASS/$smtppass/g" .muttrc



# RECEIVE EMAIL
if [[ ! -d /home/$user/Maildir ]]; then
	mkdir -p /home/$user/Maildir/{cur,new,tmp}
	chmod -R 700 /home/$user/Maildir
	cat .muttrc | sed "s/USER/$user/g" > /home/$user/.muttrc
	cp .mailcap /home/$user/
	chown -R $user:$user /home/$user
	printf "\n\n#############################\n"
	echo "TEST RECEIVING EMAIL:"
	echo "From an external email account (gmail, etc) send an email to $user@$domain"
	printf "I will tell you when I see it here"
	found=""
	while [[ $found == "" ]]; do
		printf "."
		sleep 2
		found=$(find /home/$user/Maildir/new -type f)
	done
	echo "You got mail!"
	echo ""
fi



# SMTP AUTH CREDENTIALS 
if [[ ! -f $(my smtpapi) ]]; then
	printf "\n\n#############################\n"
	echo "TO SEND EMAILS:"
	echo "1. Go to https://www.smtp2go.com/"
	echo "Click [Try SMTP2GO Free]"
	echo "Under 'Start your free account', when it asks your 'Work email',"
	echo "Type $user@$domain then click [Continue]"
	echo "Give your name and make up a password just for them."
	echo "After that, it should say 'Check your inbox!'"
	printf "Waiting for that email"
	found=""
	while [[ $found == "" ]]; do
		printf "."
		sleep 2
		found=$(grep -Ehom 1 "https://app\.smtp2go\.com/onboarding/activate/[^\"[:space:]]*" /home/*/Maildir/new/*)
	done
	echo ""
	echo ""
	echo "################# IMPORTANT:"
	echo "COPY THIS URL and PASTE it into your WEB BROWSER:"
	echo "$found/"
	echo ""
	echo "After it activates your account, DON'T 'Add a verified sender', instead..."
	echo "Click 'Get an SMTP username or API key'"
	echo "then click [Create an API Key]"
	echo "then click [Continue]"
	echo "then click [Add API Key] on the far right"
	echo "then click [Copy] to the right of the API Key"
	echo "then click [Save]"
	echo "Once you see it on the 'API Keys' screen, paste it here: "
	read ui
	# strip whitespace
	smtpapi=$(echo "$ui" | tr -d '[:space:]')
	echo $smtpapi > $(my smtpapi)
fi

if [[ ! -f $(my smtp2go) ]]; then
	smtpapi=$(cat $(my smtpapi))

	echo "Adding $domain as sender."
	json=$(curl --request POST --url https://api.smtp2go.com/v3/domain/add --header "X-Smtp2go-Api-Key: $smtpapi" --header "accept: application/json" --header "content-type: application/json" --data "{\"domain\": \"$domain\"}")
	dkim=$(echo $json | perl -ne 'print "$1" if /"dkim_selector": "([^"]+)"/')
	rpath=$(echo $json | perl -ne 'print "$1" if /"rpath_selector": "([^"]+)"/')
	echo "dkim=$dkim, rpath=$rpath (You don't need to know those, but if they are empty, there's a problem.)"

	vultrapi=$(cat $(my vultr))
	echo "Adding DNS entries."
	data=$(printf '{"type":"CNAME", "name":"%s", "data":"%s"}' $rpath "return.smtp2go.net")
	cmd=$(printf 'curl -s "https://api.vultr.com/v2/domains/%s/records" -X POST -H "Authorization: Bearer %s" -H "Content-Type: application/json" --data '\''%s'\''' $domain $vultrapi "$data")
	eval "$cmd"
	echo ""
	data=$(printf '{"type":"CNAME", "name":"%s._domainkey", "data":"%s"}' $dkim "dkim.smtp2go.net")
	cmd=$(printf 'curl -s "https://api.vultr.com/v2/domains/%s/records" -X POST -H "Authorization: Bearer %s" -H "Content-Type: application/json" --data '\''%s'\''' $domain $vultrapi "$data")
	eval "$cmd"
	echo ""
	data=$(printf '{"type":"CNAME", "name":"%s", "data":"%s"}' "link" "track.smtp2go.net")
	cmd=$(printf 'curl -s "https://api.vultr.com/v2/domains/%s/records" -X POST -H "Authorization: Bearer %s" -H "Content-Type: application/json" --data '\''%s'\''' $domain $vultrapi "$data")
	eval "$cmd"
	echo ""

	echo "Telling smtp2go.com verify $domain DNS entries."
	curl --request POST --url https://api.smtp2go.com/v3/domain/verify --header "X-Smtp2go-Api-Key: $smtpapi" --header "accept: application/json" --header "content-type: application/json" --data "{\"requisition_ssl\": true, \"domain\": \"$domain\"}"

	smtpuser=$(cat $(my smtpuser))
	smtppass=$(cat $(my smtppass))
	echo "Creating smtp2go.com SMTP user."
	curl --request POST --url https://api.smtp2go.com/v3/users/smtp/add --header "X-Smtp2go-Api-Key: $smtpapi" --header "accept: application/json" --header "content-type: application/json" --data "{\"username\": \"$smtpuser\", \"email_password\": \"$smtppass\"}"

	#echo "your SMTP (outgoing email) username: $smtpuser"
	#echo "your SMTP (outgoing email) password: $smtppass"

	printf "\n\n##################### SUCCESS!\n"
	echo "You are all set up to send outgoing emails."
	echo "YOUR IMAP SETTINGS: (to check email from any device)"
	echo "Account type: IMAP"
	echo "Email address: $user@$domain"
	echo "Username: $user"
	echo "Password: the original secret user password you made"
	echo "Incoming mail server: $domain"
	echo "Outgoing mail server: $domain"
	echo "Connection security: SSL"
	echo "Authentication type: Basic authentication"
	echo ""
	echo "Alternatively, SSH into this server as $user and type:"
	echo "mutt"
	echo ""

	# touch file to say this section finished ok (assuming it did)
	touch $(my smtp2go)
fi


# RADICALE PER-USER
if [ ! -d /var/db/radicale/collections/collection-root/$user ]; then
	sed -i 's/#type = none/type = htpasswd/g' /etc/radicale/config
	echo "Setting up Contacts and Calendar for user $user."
	echo "For Contacts and Calendar only, make a new password that’s easy to type on your phone."
	htpasswd /etc/radicale/users $user
	chown _radicale /etc/radicale/users
	rcctl enable radicale
	rcctl restart radicale
	echo "#!/bin/sh\ncp -r /var/db/radicale /home/$user/\nchown -R $user /home/$user" > /usr/local/sbin/radbak
	chmod 700 /usr/local/sbin/radbak
	# add Radicale backup to crontab if not there already
	res=$(crontab -l|grep radbak)
	if [[ $res == "" ]]; then
		(crontab -l 2>/dev/null; echo "9\t3\t*\t*\t*\t/usr/local/sbin/radbak") | crontab - 
	fi
	# create for user
	mkdir -p /var/db/radicale/collections/collection-root/$user/{calendar,contacts}
	prop=$(printf '{"C:supported-calendar-component-set": "VEVENT", "D:displayname": "%s", "tag": "VCALENDAR"}' $domain)
	echo $prop > /var/db/radicale/collections/collection-root/$user/calendar/.Radicale.props
	prop=$(printf '{"D:displayname": "%s", "tag": "VADDRESSBOOK"}' $domain)
	echo $prop > /var/db/radicale/collections/collection-root/$user/contacts/.Radicale.props
	chown -R _radicale:_radicale /var/db/radicale
	chmod 600 /var/db/radicale/collections/collection-root/$user/calendar/.Radicale.props
	chmod 600 /var/db/radicale/collections/collection-root/$user/contacts/.Radicale.props
	printf "\n\n#############################\n"
	echo "YOU NEED TO DO THIS NOW:"
	echo "On your phone, manually add a CalDAV account for calendar."
	echo "Server: dav.$domain"
	echo "Username: $user"
	echo "Password: the one you just created"
	echo "Then, manually add a CardDAV account for contacts. Same info:"
	echo "Server: dav.$domain"
	echo "Username: $user"
	echo "Password: the one you just created"
	echo ""
	echo "AFTER THAT, TEST THE CALENDAR:"
	echo "On your phone, add a new (fake/test) calendar event to your $domain calendar."
	printf "I will tell you when I see it here"
	found=""
	while [[ $found == "" ]]; do
		printf "."
		sleep 3
		found=$(find /var/db/radicale/collections/collection-root/$user/calendar/ -maxdepth 1 -type f -name '*.ics')
	done
	echo ""
	echo "Calendar entry added!"
	echo "NOW TEST THE CONTACTS:"
	echo "On your phone, add a new (fake/test) person to your $domain contacts."
	printf "I will tell you when I see it here"
	found=""
	while [[ $found == "" ]]; do
		printf "."
		sleep 3
		found=$(find /var/db/radicale/collections/collection-root/$user/contacts/ -maxdepth 1 -type f -name '*.vcf')
	done
	echo ""
	echo "Contact added! Both work. Congratulations."
fi

printf "\n\n#############################\n"
echo "For updates and help, please see https://sive.rs/ti"
echo "When your server is set up, please email me your URL."
echo "(I worked hard on this, so I like to know it helped.)"
echo "Or ask any questions, or give any suggestions."
echo ""
echo "Derek Sivers"
echo "https://sive.rs/contact"
printf "#############################\n\n"

