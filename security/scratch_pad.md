# Scratch Pad

**The following are a collection of things that I often forget :-)**

https://sites.uw.edu/rkillam/2020/03/14/cybersecurity-links/

## Windows Security Log Filters

**4624** Successful Login

**4625** Failed Login

**4672** Special Login

## Windows System Log Filters

**7045** New Created Service

## Linux Admin Tasks

```
$ md5sum package.rpm
```

View sessions by port

```
$ netstat -antlp
	tcp 0 0 192.168.1.200:22 192.168.1.100:54130 ESTABLISHED
```

Review shell commands used by the last session

```
$ cat .bash_history
```
or
```
$ history
```

```
$ sudo truncate -s 0 /var/log/messages
```

```
$ route -n
```

```
$ sudo netdiscover -r 192.168.1.0/24
```

```
$ nmap -sn 192.168.1.0/24
```

```
$ sudo zenmap &
```

```
$ sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0 && route add default gw 192.168.1.1
```

```
$ scp /root/Desktop/file.txt user@192.168.1.100:/home/user
```

```
$ crontab -e
// m h dom m dow /bin/cmd
// minute(s) 0-59 hour(s) 0-23 day(s) 1-32 month(s) 1-12 weekday(s) 0-6 command(s) 0-23
// @daily /bin/cmd
$ crontab -l
```

```
$ sudo useradd -m -d /home/newUser newUser
```

```
$ sudo passwd newUser
```

```
$ sudo cat /etc/passwd
```
or
```
$ getent passwd | grep newUser
```

```
$ sudo groupadd testUsers
$ sudo usermod -g testUsers newUser
$ id newUser
$ sudo chgrp testUsers file.txt
$ cat /etc/group
```
or
```
$ getent group | grep testUsers
$ sudo chown user01 ssh.txt
$ mysql -h 192.168.1.100 -u kali -p
Enter Password:
// win file share
smb://192.168.1.100
```

## IPTABLES

```
// log
$ sudo iptables -A INPUT -s 192.168.1.1 -j LOG --log-prefix "Top Talker "

// view log
$ sudo cat /var/log/messages | grep "Top Talker"
//or
$ sudo cat /var/log/kern.log  | grep "Top Talker"

// drop
$ sudo iptables -A INPUT -s 192.168.1.1 -j DROP

// list
$ sudo iptables -L --line-numbers

// delete log and filter
$ sudo iptables -D INPUT 1
$ sudo iptables -D INPUT 1

// saving rules
$ sudo iptables-save 

// flush logs
$ sudo truncate -s 0 /var/log/messages
$ sudo truncate -s 0 /var/log/kern.log
```

## STRINGS | PDF-PARSER | PDFTK | CLAMSCAN

```
$ strings
$ pdf-parser -v pdfFile.pdf
// -v display malformed pdf elements
```

```
$ sudo clamscan pdfFile.pdf
```

```
$ pdftk pdfFile.pdf output decoded.pdf uncompress
$ clamscan decoded.pdf
$ pdf-parser decoded.pdf
```

```
$ /usr/bin/freshclam
```

```
$ sudo systemctl status cron.service
// cron 0 1 * * * /usr/bin/freshclam
```

## SAMDUMP2 | JOHN

```
$ samdump2 system sam > winHashes.txt
// reg save HKLM\SYSTEM
// reg save HKLM\SAM
$ john winHashes.txt
```

```
$ cd /ect
$ sudo unshadow passwd shadow > ~/Documents/linuxHashes.txt
$ john linuxHashes.txt
```

## TIGER | LYNIS | Microsoft Baseline Security Analyzer (MBSA)

```
$ sudo tiger
$ cat /var/log/tiger/security.report* > tigerReport.txt
```

```
$ sudo lynis audit system > lynisReport.txt
```

## OPENVAS | Greenbone Security Assistant (GSA)(GVM)

```
$ openvas-start
// or
$ sudo gvm-start
$ netstat -antlp
$ openvas-check-setup
// or
$ sudo gvm-check-setup
```

### YAF | RWFLOWPACK | RWFILTER | RWCUT | RWUNIQ

```
// tshark note
$ tshark -i eth0 -w tcap
$ wp2yaf2silk --in=tcap --out=tcap.rw

// yaf
$ man yaf | grep ipfix

// "yaf --live pcap --in eth1 --out 127.0.0.1 --ipfix tcp --ipfix-port=18001 --applabel"
$ sudo nohup /usr/local/bin/yaf --silk --live=pcap --in=eth0 --out=127.0.0.1 --ipfix=tcp --ipfix-port=18001 --applabel --max-payload=384 &
$ service rwflowpacks status

// need rwfiltert to read
$ cat /var/log/rwflowpack-*.log
$ sudo /usr/local/bin/rwfilter --sensor=S0 --proto=0-255 --pass=stdout --type=all | rwcut

// rwp2yaf2silk rwcut rwuniq
$ /usr/local/bin/rwp2yaf2silk --in=captureFile.pcap --out=captureData.rw
$ cat captureData.rw | rwcut
$ cat captureData.rw | rwuniq --fields=sip,dip --flows=5
```

## Foremost Clone and Recover

```
$ sudo fdisk /dev/sdb
:p
:n
:w
$ sudo mkfs -t ext4 /dev/sdb
$ sudo mount /dev/sdb ~/Desktop
$ sudo dd if=/dev/sda of=~/Desktop/image.img
$ foremost -t jpg -i ~/Desktop/image.img -o foremostResults
// image.img = disk image
```

## SECURITY ONION | SUGIL | KIBAN

```
$ sudo sostart
// $ sudo so-allow
$ sudo sostat
$ sudo sostat-quick
$ sudo sostat-redacted
$ cd /etc/nsm
$ cd /etc/nsm/rules
$ nano local.rules
	alert icmp any any <> any any (msg:"ICMP"; sid:1000;)
	alert tcp any any <> any 22 (msg:"SSH"; sid:1010)
	// content:"string";
	alert udp any any <> any any (msg:"lnt3rn3tK@tz Virus Detected"; content:"lnt3rn3tK@tz"; sid:1020;)
	// threshold: type threshold, track by_dst, count 2, seconds 5
	alert udp any any <> any any (msg:"lnt3rn3tK@tz Virus Detected"; threshold: type threshold, track by_dst, count 2, seconds 5; sid:1030;)
$ sudo rule-update
```

## Poisoned Route Lab

```
$ sudo ip -s -s neigh flush all
$ arp -a
$ cd /etc
$ sudo nano ether
// gwIP MAC
$ cd /network/if-up.d
$ sudo nano StaticArp
	#!/bin/sh
	arp -f /etc/ether
$ sudo chmod u+x StaticArp
$ sudo /etc/init.d/networking restart
$ sudo /etc/init.d/networking status
```

## Review Tasks
- Check a PDF using these hints: s, p, pk
- Check a PDF using clamscan
- Get a fresh clam
- Crack a Windows password
- Crack a Linux password
- Scan a Linux systems using these hints: t, l
- What are the 3 Windows security log filters and 1 systems log filter numbers?
- Check openvas and GSA setup
- On openvas and GSA setup error, run
- Start yaf
- Check yaf flow
- cat yaf flow log
- Setup a stdout yaf sensor and view
- Convert a pcap to silk
- Read converted pcap
- Filter converted pcap
- Clone disk and use foremost
- Start security onion and check it's status
- What are the 2 security onion status modifiers?
- What are snort rules stored?
- Edit a snort rule
- Respond to a poisoned gateway route
- 3 net scans
- Change a Linux system's IP and gate
- Transfer a file to a Linux system
- cron
- Manage a user and groups
