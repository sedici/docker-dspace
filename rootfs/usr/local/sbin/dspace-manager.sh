#!/bin/bash
set -e


#########################################################
########## GENERAL HELPER FUNCTIONS #####################
#########################################################

# @param 1 (optional) Confirmation message
# @returns user answer 0=yes, -1=no
confirm() {
    local message=${1:-'Are you sure? [y/N]'}
	# call with a prompt string or use a default
    read -r -p "$message" response
	response=${response,,} 
    if [[ $response =~ ^(yes|y|Y) ]]; then
		return 0
    else
        return -1
    fi
}

print_err(){
    echo -e "\n===================================================="
	printf "[ERROR] %s\n" "$*" >&2;
    echo -e "\n===================================================="
    exit 1;
}

print_warn(){
	printf "[WARN] %s\n" "$*";
}

print_info(){
	printf "[INFO] %s\n" "$*";
}

# @param 1 (required) property name to look for
# @param 2 (required) java properties file name 
# @returns property value if found, null otherwise
get_dspace_property () {
	local cfg_file=${2}
    grep "^${1}\s*\=" ${cfg_file} |cut -d'=' -f2
}

# add the property=value assignment in a java properties file or override it if already exists
# @param 1 (required) property name
# @param 2 (required) property value 
# @param 3 (required) java properties  file name 
set_dspace_property (){
	local propval="${1} = ${2}"
	local cfg_file=${3}
	if [[ ! -f "$cfg_file" ]]; then
		print_warn "El archivo ${cfg_file} no existe, no se puede continuar"
		touch $cfg_file

	fi
	local oldval=$(get_dspace_property $1 $cfg_file)
	if [ -z "${oldval}" ]; then
        echo $propval >> ${cfg_file}
	else
        sed -i "s#^${1}.\?=.*#${propval}#" $cfg_file
    fi
}
#########################################################
######### POSTGRES HELPER FUNCTIONS #####################
#########################################################

# executes a given command in postgres using context credentials 
# @param 1 (required) command
# @returns psql return code
run_pg(){

        export PGUSER="${POSTGRES_DB_USER}"
        export PGPASSWORD="${POSTGRES_DB_PASS}"

    	psql -h ${POSTGRES_DB_HOST} -p ${POSTGRES_DB_PORT} -d ${POSTGRES_DB_NAME} -c "${1}"

		result=$?
        unset PGPASSWORD
        unset PGUSER

		return $result
}

# Test db connection using context credentials and exit on failure
test_db_connection (){
	local canconnect=$(run_pg "\\connect")
	if [[ ! $? -eq 0 ]]; then
		print_err "PSQL connection error: Could not connect using HOST=$POSTGRES_DB_HOST PORT=$POSTGRES_DB_PORT DBNAME=$POSTGRES_DB_NAME USER=$PGUSER and PGPASSWORD=$PGPASSWORD"
	fi
}

# Enable pg_crypto if is not enabled 
enable_pg_crypto()
{
        isPgCryptoInstalled=$(run_pg "\dx pgcrypto" )
		if [[ ! $? -eq 0 ]]; then
            print_err "PSQL connection error: Cannot connect using HOST=$POSTGRES_DB_HOST PORT=$POSTGRES_DB_PORT DBNAME=$POSTGRES_DB_NAME USER=$PGUSER and PGPASSWORD=$PGPASSWORD"
        fi

        if [[ ! $(echo $isPgCryptoInstalled | grep pgcrypto | wc -l) -eq 1 ]]; then
                print_warn "pgcrypto not installed in database"
                wasPgCryptoInstalled=$(run_pg "CREATE EXTENSION pgcrypto;")

                if [[ ! $? -eq 0 ]]; then
                	print_err "PSQL connection error: Cannot create extension PGCRYPTO"
                fi
                print_info "OK pgcrypto extension created"
        else
			print_info "OK pgcrypto extension is available"
		fi
}

#########################################################
#########################################################

# Init script environment
init_env () {
	#looks for POSTGRES ENV VARS 
	if [ ! -z $DB_PORT ]; then
		# DB_PORT is something like tcp://127.0.0.4:5432/
		POSTGRES_DB_HOST=`echo $DB_PORT | cut -d / -f 3 | cut -d \: -f 1`
		POSTGRES_DB_PORT=`echo $DB_PORT | cut -d / -f 3 | cut -d \: -f 2`
		POSTGRES_DB_NAME=${DB_ENV_POSTGRES_DB:-$POSTGRES_DB_NAME}
		POSTGRES_DB_USER=${DB_ENV_POSTGRES_USER:-$POSTGRES_DB_NAME}
		POSTGRES_DB_PASS=${DB_ENV_POSTGRES_PASSWORD:-$POSTGRES_DB_PASS}
	fi

	# export 
	export DSPACE_SOURCE=$DSPACE_BASE/source
	export DSPACE_DIR=$DSPACE_BASE/install

	SOURCE_CFG_FILENAME="$DSPACE_SOURCE/dspace/config/local.cfg"
	INSTALL_CFG_FILENAME="$DSPACE_DIR/config/local.cfg"

	TOMCAT="${CATALINA_HOME}/bin/catalina.sh"
}

init_sources()
{
	# download sources
	git clone -v --progress --depth=1 --branch "${DSPACE_GIT_REVISION}" "${DSPACE_GIT_URL}"  $DSPACE_SOURCE

	#creates local.cfg if it does not exist
	if [[ ! -f "$SOURCE_CFG_FILENAME" ]]; then
		cp "$SOURCE_CFG_FILENAME.EXAMPLE" "$SOURCE_CFG_FILENAME"
	fi
}

# Init DSpace local.cfg with contextual settings
init_config() {
	local cfg_file=${1}

	set_dspace_property "db.url" "jdbc:postgresql://${POSTGRES_DB_HOST}:${POSTGRES_DB_PORT}/${POSTGRES_DB_NAME}" $cfg_file
	set_dspace_property "db.username" "${POSTGRES_DB_USER}" $cfg_file
	set_dspace_property "db.password" "${POSTGRES_DB_PASS}" $cfg_file
	set_dspace_property "dspace.dir" "${DSPACE_DIR}" $cfg_file
	
	#this allows truncating the database
	set_dspace_property "db.cleanDisabled" "false" $cfg_file
}


truncate_all (){
	
	init_config $INSTALL_CFG_FILENAME
	if ( confirm "Esta por borrar el directorio de instalación de dspace $DSPACE_DIR y la base de datos, está seguro que desea hacerlo? [Y/n]" ); then
		print_info "Hago el clean y migrate de la BD para limpiarla. Si falla al crear el admin es porque el migrate no esta creando el group admin"
		dspace database clean
		enable_pg_crypto
		dspace database migrate

		rm -rf $DSPACE_DIR/*
	else
		print_err "Operación cancelada."
	fi
}

rebuild_installer(){

	init_config $SOURCE_CFG_FILENAME
	
	#MAVEN_OPTS="--batch-mode --errors --fail-at-end --show-version -DinstallAtEnd=true -DdeployAtEnd=true"
	if [ ! -z "$DSPACE_WEBAPPS" ]
	then 
		[[ $DSPACE_WEBAPPS != *"jspui"* ]] && MAVEN_OPTS="$MAVEN_OPTS -P-dspace-jspui"
		[[ $DSPACE_WEBAPPS != *"xmlui"* ]] && MAVEN_OPTS="$MAVEN_OPTS -P-dspace-xmlui"
		# if mirage2 is enabled use mirage2 settings, else disable mirage2 profile
		[[ $DSPACE_WEBAPPS = *"mirage2"* ]] && MAVEN_OPTS="$MAVEN_OPTS -Dmirage2.on=true -Dmirage2.deps.included=true" || MAVEN_OPTS="$MAVEN_OPTS -P-dspace-xmlui-mirage2"
		[[ $DSPACE_WEBAPPS != *"sword"* ]] && MAVEN_OPTS="$MAVEN_OPTS -P-dspace-sword"
		[[ $DSPACE_WEBAPPS != *"swordv2"* ]] && MAVEN_OPTS="$MAVEN_OPTS -P-dspace-swordv2"
		[[ $DSPACE_WEBAPPS != *"rdf"* ]] && MAVEN_OPTS="$MAVEN_OPTS -P-dspace-rdf"
		[[ $DSPACE_WEBAPPS != *"rest"* ]] && MAVEN_OPTS="$MAVEN_OPTS -P-dspace-rest"
		[[ $DSPACE_WEBAPPS != *"oai"* ]] && MAVEN_OPTS="$MAVEN_OPTS -P-dspace-oai"
	fi

	cd $DSPACE_SOURCE

	if [[ $1 == "fast" ]]; then
		cd dspace
	fi
	# git config --global url.https://github.com/.insteadOf git://github.com/

	print_info "Packaging dspace with MAVEN_OPTS='$MAVEN_OPTS'. "
	print_info "Please be patient, it may take several minutes. "
	mvn package $MAVEN_OPTS
}

enable_webapps(){
	print_info "Creating symlinks for webapps"

	#delete symlinks if exist
	if [ ! -z "`ls -A $CATALINA_HOME/webapps/`" ]; then
		rm $CATALINA_HOME/webapps/* 
	fi

	#enable ROOT Webapp
	root_wa="$DSPACE_ROOT_WEBAPP"
	if [ ! -z "$root_wa" ]; then
		#TODO test existence of $DSPACE_DIR/webapps/$root_wa
		ln -s $DSPACE_DIR/webapps/$root_wa $CATALINA_HOME/webapps/ROOT
	fi

	#enable all webapps
	for wa in $DSPACE_DIR/webapps/*
	do 
		if [ "$root_wa" != "$wa" ]; then
			ln -s $wa $CATALINA_HOME/webapps/$(basename $wa)
		fi
	done

	print_info "Se activaron las siguientes webapps: `ls $CATALINA_HOME/webapps/`"
}
#########################################################
#########################################################
start () {
	
	if [ ! -d $DSPACE_DIR ]; then
		print_err  "El directorio de instalación ${DSPACE_DIR} no existe, debe instalar!"
	fi
	
	init_config $INSTALL_CFG_FILENAME
	test_db_connection

	enable_webapps

	$TOMCAT run
}

install (){

	if [ -d $DSPACE_DIR ]; then
		if ( confirm "Previous DSpace installation found. Desea reinstalar? [Y/n]"); then
			truncate_all
		else
			print_err "Instalación cancelada"
		fi
	fi

	if [ ! -d $DSPACE_SOURCE ]; then
		init_sources
	fi

	# $TOMCAT stop &> /dev/null
	rebuild_installer
	enable_pg_crypto

	cd $DSPACE_SOURCE/dspace/target/dspace-installer
	ant fresh_install

	print_info "Creating admin user"
	dspace create-administrator 
	#--email ${ADMIN_EMAIL} --first DSpace --last Administrator --language es --password -${ADMIN_PASSWD} 

	#re? enable all webapps
	enable_webapps

	# do no init discovery index as solr is required and is not available
	# dspace index-discovery
}

update () 
{
	# $TOMCAT stop > /dev/null
	rebuild_installer $1
	cd $DSPACE_SOURCE/dspace/target/dspace-installer
	ant clean_backups update
	cd $DSPACE_SOURCE 
	mvn clean
	# $TOMCAT start > /dev/null
}

usage() {
	#TODO UPDATE MSG
		echo "     - install"
		echo "     - truncate"
		echo "     - update"
		echo "     - update-fast: build inside dspace dir (compiles only customizations)"
		echo "     - start"
		exit 1
}

just_wait() 
{
	tail -n 10 ${DSPACE_DIR}/log/dspace.log
	#tail -F /etc/hosts
	#-l "tail -F ${CATALINA_HOME}/logs/catalina.out" -l "tail -F ${DSPACE_DIR}/log/dspace.log"
}
#########################################################
#########################################################

#validates current user be the same as DSPACE_USER
if [ ! "id ${DSPACE_USER} 2> /dev/null | grep $DSPACE_USER" ]; then
	print_err "El usuario que está ejecutando este comando no es el usuario predefinido de dspace '$DSPACE_USER', no se permite usar otro usuario para evitar problemas de permisos en el directorio de instalación."
fi

cd $DSPACE_BASE

# se hace el "source ~/.bashrc" para importar las cfgs de mirage2 
# source ~/.bashrc

init_env
case "$1" in
  	start)
		start
		just_wait
		;;
	# init_sources)
		# init_sources
		# ;;
  	install)
		install
		;;
  	update)
		update
        ;;
  	update-fast)
		update fast
        ;;
  	*)
        usage
        ;;
esac
exit 0