#!/bin/bash
set -e

touch ~/.bash_profile ~/.bashrc

#curl, wget , sudo 
echo "${DSPACE_USER} ALL= NOPASSWD:ALL" > /etc/sudoers.d/rvm


su --login $DSPACE_USER  <<EOF 
#Mirage dependencies

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash 
source ~/.bashrc
#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm


nvm install 12 
nvm alias default 12
npm install -g bower
npm install -g grunt
npm install -g --force grunt-cli

gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB 
command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

curl -sSL https://get.rvm.io | bash -s stable  --ruby --auto-dotfiles
source ~/.rvm/scripts/rvm

#rvm install ruby --default
#rvm pkg install libyaml
source ~/.bashrc
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 
gem install sass -v 3.3.14 --no-document && gem install compass -v 1.0.1 --no-document


#echo 'export PATH="\$PATH:\$HOME/.rvm/bin"' >> ~/.bash_profile
#echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*' >> ~/.bashrc
EOF
rm  /etc/sudoers.d/rvm
