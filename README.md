# Docker container for [DSpace]


## Requirements

  - Install [Docker] && [docker-compose] 

## Installation
1. > git clone https://github.com/sedici/dspace-docker/
2. > cd dspace-docker
3. > docker-compose build
4. > docker-compose run dspace install
5. > docker-compose up
6. > Access http://localhost:9090/

## Making changes in dev
1. change ```data/sources/*``` as desired
2. run ```docker-compose run dspace update``` or ```docker-compose run dspace update-fast```
3. wait for tomcat to detect changes and reload the webapps 

## TODO

  - set tomcat Xmx, Xms, and more in setenv.sh
  - Mirar https://github.com/docker-library/official-images#library-definition-files 
  - implement cronjobs
  - add authority managment service
  - better dspace logs rotation
  - use # TODO por ahora solo se permite github
  - split dspace in data and source dirs? 



## Some ideas inspired in  

- https://github.com/alanorth/docker-dspace
- https://github.com/kerojohan/DSpace6_0-docker
- https://github.com/QuantumObject/docker-dspace
- https://github.com/4Science/dspace-docker
- https://github.com/uner-digital/DSpace/wiki/
- https://docs.docker.com/develop/dev-best-practices/#how-to-keep-your-images-sm





[Docker-Install]:https://docs.docker.com/engine/installation/
