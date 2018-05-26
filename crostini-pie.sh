#!/usr/bin/env bash

required="build-essential pkg-config git stow"
optional="gnupg tmux rsync mosh wget iputils-ping dnsutils"
extras="bc keychain vim-nox fonts-noto mu4e"

ingredients="sethostname \
        setrepos \
        backports \
        extras \
        termite \
        fish-shell \
        ansible \
        terraform \
        packer \
        emacs \
"

function add_ingredient {
    case $1 in
        sethostname)
            # Set hostname: The container needs to be called penguin, at least if you want to use the app shortcut
            # But you can rename the host.
            # You may get a complaint from sudo saying "unable to resolve host <whatever old name>". Safe to ignore it
            read -p "## Enter hostname for this container: " newname ; \
            echo "## It's safe to ignore the following sudo warning"
            sudo sed -i "s/127\.0\.1\.1.*/127\.0\.1\.1\t${newname}/" /etc/hosts
            sudo hostnamectl set-hostname ${newname} ; \
            ;;

        setrepos)
            # Add contrib, non-free Debian repos, as well as backports
            # These are in a separate file in /etc/apt/sources.lists.d for easy removal if desired
            sudo sh -c 'cat > /etc/apt/sources.list.d/crostini-pie.list' << EOF

            # Debian contrib and non-free repos as well as stretch-updates
            deb http://deb.debian.org/debian stretch contrib non-free
            deb http://deb.debian.org/debian stretch-updates main contrib non-free
            deb http://security.debian.org/debian-security/ stretch/updates contrib non-free
            deb http://ftp.debian.org/debian stretch-backports main contrib non-free
EOF
            sudo apt update
            ;;

        backports)
            # Steps through a list of packages to install, all from backports by default

            final=""
            echo "## Hit Enter to add each package to the list to be installed, or n to skip it"
            for pkg in ${optional}; do
                    read -p "#### Install ${pkg}? (Y/n)" yorn
                    case ${yorn} in
                        n)
                            echo "#### Skipping ${pkg}"
                            ;;
                        *)
                            echo "#### Adding ${pkg} to the install list"
                            final="${final} ${required} ${pkg}"
                            ;;
                    esac
            done
            echo "##### Final list of packages:"
            echo "${final}"
            sudo apt-get -y -t stretch-backports install ${final}
            ;;

        extras)
            # Steps through a list of packages to install, all from backports by default

            final=""
            echo "## Hit Enter to add packages from the EXTRAS to the list to be installed, or n to skip it"
            for pkg in ${extras}; do
                    read -p "#### Install ${pkg}? (Y/n)" yorn
                    case ${yorn} in
                        n)
                            echo "#### Skipping ${pkg}"
                            ;;
                        *)
                            echo "#### Adding ${pkg} to the install list"
                            final="${final} ${pkg}"
                            ;;
                    esac
            done
            echo "##### Final list of packages:"
            echo "${final}"
            sudo apt-get -y -t stretch-backports install ${final}
            ;;

        termite)
            # from https://github.com/Corwind/termite-install/blob/master/termite-install.sh
            sudo apt-get install -y \
                git \
                g++ \
                libgtk-3-dev \
                gtk-doc-tools \
                gnutls-bin \
                valac \
                intltool \
                libpcre2-dev \
                libglib3.0-cil-dev \
                libgnutls28-dev \
                libgirepository1.0-dev \
                libxml2-utils \
                gperf

            git clone --recursive https://github.com/thestinger/termite.git
            git clone https://github.com/thestinger/vte-ng.git

            echo export LIBRARY_PATH="/usr/include/gtk-3.0:$LIBRARY_PATH"
            cd vte-ng && ./autogen.sh && make && sudo make install
            cd ../termite && make && sudo make install
            sudo ldconfig
            sudo mkdir -p /lib/terminfo/x; sudo ln -s \
            /usr/local/share/terminfo/x/xterm-termite \
            /lib/terminfo/x/xterm-termite

            sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/termite 60
            ;;

        fish-shell)
            # From: https://software.opensuse.org/download.html?project=shells%3Afish%3Arelease%3A2&package=fish
            sudo sh -c 'cat > /etc/apt/sources.list.d/shells:fish:release:2.list' << EOF
            deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_9.0/ /
EOF
            wget -nv https://download.opensuse.org/repositories/shells:fish:release:2/Debian_9.0/Release.key -O fishshell.key
            sudo apt-key add - < fishshell.key
            sudo apt-get update
            sudo apt install fish
            ;;

        ansible)
            #Source: http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-debian
            # When you run the next command you'll get an error about the gpg key for the ansible ppa
            sudo sh -c 'cat > /etc/apt/sources.list.d/ansible.list' << EOF
            deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
EOF
            sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
            sudo apt-get update
            sudo apt-get -y install ansible
            ;;
        terraform)
            TFVersion="${choice:-0.11.7}"
            echo "#### Default terraform version is ${TFVersion}"
            curl -o terraform_${TFVersion}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TFVersion}/terraform_${TFVersion}_linux_amd64.zip
            unzip terraform_${TFVersion}_linux_amd64.zip
            rm terraform_${TFVersion}_linux_amd64.zip
            sudo mkdir -p /usr/local/stow/terraform
            sudo mv terraform /usr/local/stow/terraform/terraform-${TFVersion}
            cd /usr/local/stow/terraform
            sudo ln -s terraform-${TFVersion} terraform
            cd ..
            sudo stow -t /usr/local/bin terraform
            cd
            ;;

        packer)
            PKVersion="${choice:-1.2.3}"
            echo "#### Default packer version is ${PKVersion}"
            curl -o packer_${PKVersion}_linux_amd64.zip https://releases.hashicorp.com/packer/${PKVersion}/packer_${PKVersion}_linux_amd64.zip
            unzip packer_${PKVersion}_linux_amd64.zip
            rm packer_${PKVersion}_linux_amd64.zip
            sudo mkdir -p /usr/local/stow/packer
            sudo mv packer /usr/local/stow/packer/packer-${PKVersion}
            cd /usr/local/stow/packer
            sudo ln -s packer-${PKVersion} packer
            cd ..
            sudo stow -t /usr/local/bin packer
            cd
            ;;
        emacs)
            git clone -b master git://git.sv.gnu.org/emacs.git
            sudo apt-get -y install build-essential automake texinfo libjpeg-dev libncurses5-dev
            sudo apt-get -y install libtiff5-dev libgif-dev libpng-dev libxpm-dev libgtk-3-dev libgnutls28-dev
            cd emacs/
            ./autogen.sh
            ./configure --with-mailutils --prefix=/usr/local/stow/emacs
            make
            sudo make install
            cd /usr/local/stow
            sudo stow emacs
            ;;
        *)  echo "That's all"
            ;;
    esac
}

function doyouwant {
    echo ""
    echo "## About to execute function: ${i}"
    echo "## Enter to proceed, n to skip this ingredient, or any other input will be treated as parameters for the function"
    read -e -p "## Install $1? (Y/n/args) " choice
    echo ""
    case ${choice} in
        n|N)    echo "## Skipping $1"
            ;;
        *)  echo "## Executing $1"
            add_ingredient $1 $choice
            ;;
    esac
}

for i in ${ingredients}; do
    doyouwant $i
done
