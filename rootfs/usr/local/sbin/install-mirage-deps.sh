#!/bin/bash
set -e
#curl, wget , sudo 
echo "${DSPACE_USER} ALL= NOPASSWD:ALL" > /etc/sudoers.d/rvm


su --login $DSPACE_USER  <<EOF 
#Mirage dependencies

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.7/install.sh | bash 
nvm install 6.5.0 
nvm alias default 6.5.0
npm install -g bower
npm install -g grunt
npm install -g grunt-cli

command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable --ruby
# rvm install ruby --default
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 
gem install sass -v 3.3.14 --no-document && gem install compass -v 1.0.1 --no-document


echo 'export PATH="\$PATH:\$HOME/.rvm/bin"' >> ~/.bash_profile
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*' >> ~/.bashrc
EOF
# mvn package -Dmirage2.on=true -Dmirage2.deps.included=false
rm  /etc/sudoers.d/rvm
