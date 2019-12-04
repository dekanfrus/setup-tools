#!/bin/bash

# Global Variables
userid=`id -u`
osinfo=`cat /etc/issue|cut -d" " -f1|head -n1`
eplpkg='http://linux.mirrors.es.net/fedora-epel/6/i386/epel-release-6-8.noarch.rpm'

RED='\033[0;31m'
GRN='\033[0;32m'
NC='\033[0m'

wdir=`pwd`

{
	clear
	
	echo '#######################################################################'
	echo '#                       dekanfrus kali setup                          #'
	echo '#######################################################################'
	echo
	
	if [ "${userid}" != '0' ]; then
	  echo '[Error]: You must run this setup script with root privileges.' >&3
	  echo
	  exit 1
	fi
	
	echo -e "${GRN} [+] Updating System. Please Be Patient.${NC}" >&3
	apt-get update -qq && apt-get -o Dpkg::Use-Pty=0 install kali-defaults -qq && apt-get -o Dpkg::Use-Pty=0 install kali-linux-full -qq && apt-get upgrade -o Dpkg::Use-Pty=0 -qq && apt-get dist-upgrade -qq -o Dpkg::Use-Pty=0
	apt-get -o Dpkg::Use-Pty=0 install libsasl2-dev python-dev libldap2-dev libssl-dev cmake python3 xvfb python3-pip python-netaddr python3-dev tesseract-ocr firefox-esr kali-root-login desktop-base kde-plasma-desktop python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev tilix -qq
	
	# Suppress stdout
	exec 3>&1 1>/dev/null
	
	echo -e "${GRN} [+] Installing Python Modules${NC}" >&3
	python3 -m pip install fuzzywuzzy 
	python3 -m pip install selenium --upgrade 
	python3 -m pip install python-Levenshtein 
	python3 -m pip install pyasn1 
	python3 -m pip install pyvirtualdisplay 
	python3 -m pip install beautifulsoup4 
	python3 -m pip install pytesseract 
	python3 -m pip install netaddr 
	python2 -m pip install python-ldap 
	python3 -m pip install pycurl 
	python3 -m pip install paramiko 
	python3 -m pip install ajpy 
	python3 -m pip install pyopenssl 
	python3 -m pip install cx_Oracle 
	python3 -m pip install mysqlclient 
	python3 -m pip install psycopg2-binary 
	python3 -m pip install pycrypto 
	python3 -m pip install dnspython 
	python3 -m pip install IPy 
	python3 -m pip install pysnmp 
	python3 -m pip install pyasn1 
	python3 -m pip install yara-python
	python3 -m pip install truffleHog
	
	pip3 install pipenv && pipenv install --three 
	PYTHON_BIN_PATH="$(python3 -m site --user-base)/bin"
	PATH=$PATH:$PYTHON_BIN_PATH;export PATH
	
	# No python3 support
	#python3 -m pip install impacket
	#python3 -m pip install pysqlcipher
	
	echo -e "${GRN}[+] Installing VMware Tools${NC}" >&3
	apt-get install open-vm-tools-desktop -qq
	
	echo -e "${GRN}[+] Removing Default SSH Keys${NC}" >&3
	#./UpdateSSHKeys.sh
	service ssh stop 
	cd /etc/ssh/
	mkdir default_kali_keys
	mv ssh_host_* default_kali_keys/
	dpkg-reconfigure openssh-server
	service ssh start

	echo -e "${GRN}[+] Installing GOLANG${NC}" #>&3
	cd $HOME/Downloads
	wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
	tar -C /usr/local -xzf go1.13.4.linux-amd64.tar.gz
	export PATH=$PATH:/usr/local/go/bin
	rm go1.13.4.linux-amd64.tar.gz


	echo -e "${GRN}[+] Downloading and Installing Tools${NC}" >&3
	mkdir /tools/ && cd /tools
	mkdir {recon,c2,passwords,exploitation,persist,privesc,access}
	
	# Access Tools
	cd /tools/access
	echo -e "${GRN}   -- WitnessMe${NC}" >&3
		git clone --quiet https://github.com/byt3bl33d3r/WitnessMe /tools/access/witnessme && cd witnessme
	
	echo -e "${GRN}   -- EyeWitness${NC}" >&3
		git clone --quiet https://github.com/FortyNorthSecurity/EyeWitness.git /tools/access/eyewitness
		cd /tools/access/eyewitness/setup 
		bash setup.sh 

	echo -e "${GRN}   -- ShareEnum${NC}" >&3
		cd /tools/access
		wget https://github.com/CroweCybersecurity/shareenum/releases/download/2.0/shareenum_2.0_amd64.deb
		dpkg -i shareenum_2.0_amd64.deb
		rm shareenum_2.0_amd64.deb

	echo -e "${GRN}   -- jLoot${NC}" >&3
		cd /tools/access
		git clone --quiet https://github.com/netspooky/jLoot.git

	# Recon Tools
	cd /tools/recon
	echo -e "${GRN}   -- ad-ldap-enum${NC}" >&3
		git clone --quiet https://github.com/dekanfrus/ad-ldap-enum.git
	echo -e "${GRN}   -- AutoRecon${NC}" >&3
		git clone --quiet https://github.com/Tib3rius/AutoRecon
	echo -e "${GRN}   -- net-creds${NC}" >&3
		git clone --quiet https://github.com/DanMcInerney/net-creds.git

	# Password Tools
	cd /tools/passwords
	echo -e "${GRN}   -- patator" >&3
		git clone --quiet https://github.com/lanjelot/patator.git
	#echo -e "${GRN}   -- Installing...${NC}" >&3
	#	cd patator && pipenv run python3 setup.py install 
	
	# zsh, vim, tmux config
	echo -e "${GRN}[+] Installing Powerline, Fonts, and ZSH Addons${NC}" >&3
		apt-get install powerline zsh-syntax-highlighting zsh-theme-powerlevel9k vim tmux vim-addon-manager -y
		
		git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
		git clone --quiet https://github.com/gabrielelana/awesome-terminal-fonts.git ~/Downloads/fonts && cd ~/Downloads/fonts
		bash install.sh
	
		git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
	
		cd ~/Downloads
		git clone https://github.com/ryanoasis/nerd-fonts.git && cd nerd-fonts
		bash install.sh Hack

	echo "${GRN}[+] Installing LSD${NC}" >&3
		cd $HOME/Downloads
		wget "https://github.com/Peltoche/lsd/releases/download/0.16.0/lsd_0.16.0_amd64.deb"
		sudo dpkg -i lsd_0.16.0_amd64.deb
		rm lsd_0.16.0_amd64.deb

	echo "${GRN}[+] Configuring zshrc${NC}" >&3
	#cp zshrc ~/.zshrc
	#cp aliases ~/.aliases
	#cp -r .config ~/.config
	#cp .gitconfig ~/.gitconfig
	#cp -r .local ~/.local
	cd
	git init
	git remote add origin https://github.com/dekanfrus/dotfiles.git
	git pull

	#git clone https://www.github.com/dekanfrus/dotfiles ~/
	
	echo "${GRN}[+] Installing Powerline for VIM${NC}" >&3
	cd /root/Downloads
	git clone https://github.com/vim-airline/vim-airline ~/.vim/pack/dist/start/vim-airline
	git clone https://github.com/vim-airline/vim-airline-themes.git
	cp vim-airline-themes/autoload/airline/themes/* ~/.vim/pack/dist/start/vim-airline/autoload/airline/themes/
	
	#echo "${GRN}[+] Installing Powerline for tmux${NC}" >&3
	#echo "run-shell "powerline-daemon -q"" >> ~/.tmux.conf
	#echo source "/usr/share/powerline/bindings/tmux/powerline.conf" >> ~/.tmux.conf
	#echo "set-option -g default-shell /bin/zsh" >> ~/.tmux.conf
	
	echo "${GRN}[+] Setting zshell as default${NC}" >&3
	chsh -s /bin/zsh
	
	#echo "${GRN}[+] Installing USB NIC drivers" >&3
	#cd /tmp
	#wget "https://www.asix.com.tw/FrootAttach/driver/AX88179_178A_LINUX_DRIVER_v1.19.0_SOURCE.tar.bz2"
	#tar xvjf *.tar.bz2
	#cd *SOURCE
	#make
	#make install
	#modprobe asix
	#echo "[+] Reboot required!" >&3

	exec 1>&3 3>&-

} || {
	#Restore stdout
	exec 1>&3 3>&-
}
