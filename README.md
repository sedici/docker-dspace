# Docker container for [DSpace]
DSpace instant development environment using Docker Compose

## Requirements

  - Install [Docker] && [docker-compose] 
  - Have ports 9090 (tomcat), 8000 (to do remote debug) open. Otherwise, you can modify the mappings in docker-compose.yml and in docker-compose-debug.yml respectively to use whichever ports you prefer.

## Installation
1. > git clone https://github.com/sedici/dspace-docker/
2. > cd dspace-docker
3. > mkdir data/source
4. > git clone [dspace source  remote git repo] data/source
5. > Modify .env file
6. > make up
7. > make install
8. > Access http://localhost:9090/

## Making changes in dev
1. change ```data/dspace-6/sources/*``` as desired
2. run ```docker-compose run dspace update``` or ```docker-compose run dspace update-fast``` to recompile
3. wait for tomcat to detect changes and reload the webapps 

## Configure webapps installed
By default only xmlui webapp is installed. You can change it in docker-compose.yml changing the value of DSPACE_WEBAPPS variable

## Populate database
You can copy a dump file into ```data``` directory before or after running 
```docker-compose run dspace install```, if ```data``` directory doesn't exist, create it. The dump filename must be **bootstrap-dump.sql**, otherwise, modify the enviroment variable **$BOOTSTRAP_DUMP** at Dockerfile using other filename.

If you copy it before running the install command then the database will be populated automatically from your dump file, otherwise you must run 
```docker-compose run dspace reset-db```

## Remote debug of Tomcat WEBAPPS
To enable remote tomcat debug of DSpace Webapps, you must run either commands next

```make up ```

or

```docker-compose -f docker-compose.yml -f docker-compose-debug.yml up ```

You can now attach a remote debugger from your IDE just as if Tomcat were running locally. If your development machine is your Docker host, you have to attach to localhost 8000 (you can change the port in docker-compose-debug.yml).

## Remote debug of CLI DSpace commands
To enable the debug of any command executed with *DSPACE_DIR/bin/dspace* script, then you must do the following:
1. Modifiy the last line of DSpace script (at DSPACE_DIR/bin/dspace) and add the **$JPDA_CLI_OPTS** option in java incovation:
```bash
java  $JPDA_CLI_OPTS $JAVA_OPTS -classpath $FULLPATH org.dspace.app.launcher.ScriptLauncher "$@"
```
2. Barely run a dspace command, start a **Socket Attach** connection at Port **8001** in Eclipse IDE. To do this, create a new "Java Remote Application" debug configuration with the parametters specified previously.

## Remote Maven Test debug with Eclipse
First edit docker-compose-debug to bind localhost 5005 port to container's 5005 port.
Then, inside the container, go to /dspace/source and run mvn tests with 
```mvn -Dmaven.test.skip=false -Dmaven.surefire.debug test```
The test will wait for Eclipse to connect.

Open the Debug Configuration in Eclipse and set up a remote application on port 5005. Run the configuration. The test will resume. You can use break points and all the usual features of Eclipse debugging.

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
