# Docker container for [DSpace]
DSpace instant development environment using Docker Compose

## Requirements

  - Install [Docker] && [docker-compose] 
  - Have ports 9090 (tomcat), 8000 (to do remote debug) open. Otherwise, you can modify the mappings in docker-compose.yml and in docker-compose-debug.yml respectively to use whichever ports you prefer.

## Installation
1. > git clone https://github.com/sedici/dspace-docker/
2. > cd dspace-docker
3. > docker-compose build
4. > docker-compose run dspace install
5. > docker-compose up
6. > Access http://localhost:9090/

## Making changes in dev
1. change ```data/sources/*``` as desired
2. run ```docker-compose run dspace update``` or ```docker-compose run dspace update-fast``` to recompile
3. wait for tomcat to detect changes and reload the webapps 

## Configure webapps installed
By default only xmlui webapp is installed. You can change it in docker-compose.yml changing the value of DSPACE_WEBAPPS variable

## Populate database
You can copy a dump file into ```data``` directory before or after running 
```docker-compose run dspace install```, if ```data``` directory doesn't exist, create it

If you copy it before running the install command then the database will be populated automatically from your dump file, otherwise you must run 
```docker-compose run dspace reset-db```

## Remote debug
To enable remote tomcat debug instead of running
```docker-compose up ```

run 
```docker-compose -f docker-compose.yml -f docker-compose-debug.yml up ```

You can now attach a remote debugger from your IDE just as if Tomcat were running locally. If your development machine is your Docker host, you have to attach to localhost 8000 (you can change the port in docker-compose-debug.yml).

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
- https://www.dontpanicblog.co.uk/2017/03/12/tomcat-debugging-in-docker/



[Docker-Install]:https://docs.docker.com/engine/installation/
