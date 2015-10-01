#!/bin/sh
set -e

user=nowk
password=astrongpassword

if id $user > /dev/null 2>&1 ; then
	echo "User $user already exists"
else
	echo "Creating user $user"

	sudo adduser $user \
		--gecos "*" \
		--disabled-password

	sudo sh -c "echo '$user ALL=(ALL:ALL) ALL' >> /etc/sudoers"

	echo "$user:$password" | sudo chpasswd
fi

sudo apt-get update

# manual install of guest additions, debian needs this due to missing headers
sudo apt-get -y install linux-headers-`uname -r`

if [ ! -e ~/opt ] ; then
	mkdir ~/opt
fi
cd ~/opt

if [ ! -e ~/opt/VBoxGuestAdditions_5.0.2.iso ] ; then
	wget http://download.virtualbox.org/virtualbox/5.0.2/VBoxGuestAdditions_5.0.2.iso > /dev/null 2>&1
fi

if [ ! -e /mnt/miso ] ; then
	sudo mkdir /mnt/miso
fi
if grep -qs '/mnt/miso' /proc/mounts ; then
	echo "already mounted"
else
	sudo mount ./VBoxGuestAdditions_5.0.2.iso /mnt/miso
fi

# VBoxLinuxAdditions.run throws a message into stderr, absorb that with set +e
set +e
cd /mnt/miso \
	&& sudo ./VBoxLinuxAdditions.run
sudo umount /mnt/miso

cd ~/opt \
	&& rm VBoxGuestAdditions_5.0.2.iso
cd .. \
	&& rmdir opt

set -e


# add nameserver 8.8.8.8
#
echo nameserver 8.8.8.8 | sudo tee -a /etc/resolv.conf


# need ppa for latest git (trusty needs this)
# sudo apt-get -y install software-properties-common
# sudo add-apt-repository ppa:git-core/ppa
# sudo apt-get update

sudo apt-get -y install curl git-core tmux zsh

exec echo $password | sudo -S -i -u $user /bin/sh - << eof
cd

# oh my zsh
# this throws an error, absorb with set +e
set +e
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

set -e
sh -c "echo '${password}' | chsh -s $(which zsh)"

# dotfiles
git clone https://github.com/nowk/prospect.git
cd \
	&& ln -s ~/prospect ~/.prospect \
	&& ln -s ~/.prospect/gitconfig ~/.gitconfig \
	&& ln -s ~/.prospect/gitignore_global ~/.gitignore_global \
	&& ln -s ~/.prospect/tmux.conf ~/.tmux.conf \
	&& ln -s ~/.prospect/vim ~/.vim \
	&& ln -s ~/.prospect/vimrc ~/.vimrc \
	&& mv ~/.zshrc ~/.zshrc.before-ln-s \
	&& ln -s ~/.prospect/zshrc ~/.zshrc \
	&& ln -s ~/.prospect/zshrc.local ~/.zshrc.local \
	&& ln -s ~/.prospect/oh-my-zsh/themes/normalt.zsh-theme ~/.oh-my-zsh/themes/normalt.zsh-theme

# terminfos
cd ~/.prospect/terminfo \
	&& tic screen-256color-italic.terminfo \
	&& tic xterm-256color-italic.terminfo
eof

# vim
sudo apt-get -y install vim-nox

exec echo $password | sudo -S -i -u $user /bin/sh - << eof
set -e

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# supress output, it loads a vim
# send <enter>
echo | vim +PluginInstall +qall > /dev/null 2>&1
eof

# basics to compile stuff
sudo apt-get -y install \
	build-essential \
	cmake \
	software-properties-common \
	python-dev \
	python-pip \
	libncurses-dev \
	clang

exec echo $password | sudo -S -i -u $user /bin/sh - << eof
set -e
if [ ! -e ~/opt ] ; then
	mkdir ~/opt
fi

# tig
cd ~/opt \
	&& git clone https://github.com/jonas/tig.git
cd tig \
	&& make prefix=/usr/local
echo '$password' | sudo -S make install prefix=/usr/local
cd .. \
	&& rm -rf tig

# TODO remove golang, will be moving entirely to docker
# golang
cd ~/opt \
	&& git clone https://github.com/golang/go.git
cd go \
	&& git checkout go1.4.3
cd src \
	&& ./all.bash

# load the export file to get the gopaths
. ~$user/prospect/exports/golang
eof

