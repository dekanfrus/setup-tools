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
          echo '[Error]: You must run this setup script with root privileges.'
          echo
          exit 1
        fi

        if [ $SUDO_USER ]; then
                real_user=$SUDO_USER
        else
                real_user=$(whoami)
        fi

        echo -e "${GRN} [+] Updating System. Please Be Patient.${NC}"
        apt-get update -qq && apt-get -o Dpkg::Use-Pty=0 install kali-defaults -qq && apt-get -o Dpkg::Use-Pty=0 install kali-linux-full -qq && apt-get upgrade -o Dpkg::Use-Pty=0 -qq && apt-get dist-upgrade -qq -o Dpkg::Use-Pty=0
        apt-get -o Dpkg::Use-Pty=0 install libsasl2-dev python-dev libldap2-dev libssl-dev cmake python3 xvfb python3-pip python-netaddr python3-dev tesseract-ocr firefox-esr kali-root-login desktop-base kde-plasma-desktop python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev tilix xclip -qq

        # Suppress stdout
        exec 3>&1 1>/dev/null

        echo -e "${GRN} [+] Installing Python Modules${NC}" >&3
        sudo -u $real_user python3 -m pip install fuzzywuzzy
        sudo -u $real_user python3 -m pip install selenium --upgrade
        sudo -u $real_user python3 -m pip install python-Levenshtein
        sudo -u $real_user python3 -m pip install pyasn1
        sudo -u $real_user python3 -m pip install pyvirtualdisplay
        sudo -u $real_user python3 -m pip install beautifulsoup4
        sudo -u $real_user python3 -m pip install pytesseract
        sudo -u $real_user python3 -m pip install netaddr
        sudo -u $real_user python2 -m pip install python-ldap
        sudo -u $real_user python3 -m pip install pycurl
        sudo -u $real_user python3 -m pip install paramiko
        sudo -u $real_user python3 -m pip install ajpy
        sudo -u $real_user python3 -m pip install pyopenssl
        sudo -u $real_user python3 -m pip install cx_Oracle
        sudo -u $real_user python3 -m pip install mysqlclient
        sudo -u $real_user python3 -m pip install psycopg2-binary
        sudo -u $real_user python3 -m pip install pycrypto
        sudo -u $real_user python3 -m pip install dnspython
        sudo -u $real_user python3 -m pip install IPy
        sudo -u $real_user python3 -m pip install pysnmp
        sudo -u $real_user python3 -m pip install pyasn1
        sudo -u $real_user python3 -m pip install yara-python
        sudo -u $real_user python3 -m pip install truffleHog
        sudo -u $real_user python3 -m pip install pypykatz
        sudo -u $real_user python2 -m pip install xlrd
        sudo -u $real_user python3 -m pip install xlrd

        sudo -u $real_user pip3 install pipenv && pipenv install --three
        PYTHON_BIN_PATH="$(python3 -m site --user-base)/bin"
        PATH=$PATH:$PYTHON_BIN_PATH;export PATH

        # No python3 support
        sudo -u $real_user python3 -m pip install impacket
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
        cd $HOME
        sudo -u $real_user wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
        sudo -u $real_user tar -C /usr/local -xzf go1.13.4.linux-amd64.tar.gz
        sudo -u $real_user export PATH=$PATH:/usr/local/go/bin
        sudo -u $real_user rm go1.13.4.linux-amd64.tar.gz


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

        echo -e "${GRN}   -- Evil WinRM${NC}" >&3
                git clone --quiet https://github.com/Hackplayers/evil-winrm
                gem install bundler:2.0.2
                bundle update

        # Recon Tools
        cd /tools/recon
        echo -e "${GRN}   -- ad-ldap-enum${NC}" >&3
                git clone --quiet https://github.com/dekanfrus/ad-ldap-enum.git
        echo -e "${GRN}   -- AutoRecon${NC}" >&3
                git clone --quiet https://github.com/Tib3rius/AutoRecon
        echo -e "${GRN}   -- net-creds${NC}" >&3
                git clone --quiet https://github.com/DanMcInerney/net-creds.git
        echo -e "${GRN}   -- pspy${NC}" >&3
                mkdir pspy && cd pspy
                wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64s
                wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64
                wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32s
                wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32
                chmod +x pspy*
                cd /tools/recon

        # Password Tools
        cd /tools/passwords
        echo -e "${GRN}   -- patator" >&3
                git clone --quiet https://github.com/lanjelot/patator.git
        #echo -e "${GRN}   -- Installing...${NC}" >&3
        #       cd patator && pipenv run python3 setup.py install

        # Exploitation Tools
        cd /tools/exploitation
        echo -e "${GRN}   -- Sherlock${NC}" >&3
                git clone --quiet https://github.com/rasta-mouse/Sherlock.git
        echo -e "${GRN}   -- Watson${NC}" >&3
                git clone --quiet https://github.com/rasta-mouse/Watson.git
        echo -e "${GRN}   -- Windows-Exploit-Suggester${NC}" >&3
                git clone --quiet https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git
        echo -e "${GRN}   -- One-Lin3r${NC}" >&3
                pip3 install one-lin3r
                pip3 install prompt-toolkit --force-reinstall

        # installing oh-my-zsh
        sudo -u $real_user sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

        # zsh, vim, tmux config
        echo -e "${GRN}[+] Installing Powerline, Fonts, and ZSH Addons${NC}" >&3
                apt-get install powerline zsh zsh-syntax-highlighting zsh-theme-powerlevel9k vim tmux vim-addon-manager zsh-autosuggestions -y

                sudo -u $real_user git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/themes/powerlevel10k
                sudo -u $real_user git clone --quiet https://github.com/gabrielelana/awesome-terminal-fonts.git ~/fonts && cd ~/fonts
                sudo -u $real_user bash install.sh

                sudo -u $real_user cd $HOME
                sudo -u $real_user git clone https://github.com/ryanoasis/nerd-fonts.git && cd nerd-fonts
                sudo -u $real_user bash install.sh Hack

        echo "${GRN}[+] Installing LSD${NC}" >&3
                sudo -u $real_user cd $HOME
                sudo -u $real_user wget "https://github.com/Peltoche/lsd/releases/download/0.16.0/lsd_0.16.0_amd64.deb"
                sudo -u $real_user dpkg -i lsd_0.16.0_amd64.deb
                sudo -u $real_user rm lsd_0.16.0_amd64.deb

        echo "${GRN}[+] Configuring zshrc${NC}" >&3
        sudo -u $real_user cd $HOME
        sudo -u $real_user wget https://raw.githubusercontent.com/dekanfrus/dotfiles/master/zshrc -O $HOME/.zshrc
        sudo -u $real_user wget https://raw.githubusercontent.com/dekanfrus/dotfiles/master/aliases -O $HOME/.aliases
        sudo -u $real_user wget https://raw.githubusercontent.com/dekanfrus/dotfiles/master/bashrc -O $HOME/.bashrc
        sudo -u $real_user wget https://raw.githubusercontent.com/dekanfrus/dotfiles/master/dput.cf -O $HOME/.dput.cf
        sudo -u $real_user wget https://raw.githubusercontent.com/dekanfrus/dotfiles/master/p10k.zsh -O $HOME/.p10k.zsh
        sudo -u $real_user wget https://raw.githubusercontent.com/dekanfrus/dotfiles/master/vimrc -O $HOME/.vimrc
        sudo -u $real_user wget https://raw.githubusercontent.com/dekanfrus/dotfiles/master/tmux.conf -O $HOME/.tmux.conf

        echo "${GRN}[+] Installing Powerline for VIM${NC}" >&3
        sudo -u $real_user cd $HOME
        sudo -u $real_user git clone https://github.com/vim-airline/vim-airline ~/.vim/pack/dist/start/vim-airline
        sudo -u $real_user git clone https://github.com/vim-airline/vim-airline-themes.git
        sudo -u $real_user cp vim-airline-themes/autoload/airline/themes/* ~/.vim/pack/dist/start/vim-airline/autoload/airline/themes/

        echo "${GRN}[+] Setting zshell as default${NC}" >&3
        sudo -u $real_user chsh -s /bin/zsh

        exec 1>&3 3>&-

} || {
        #Restore stdout
        exec 1>&3 3>&-
}
