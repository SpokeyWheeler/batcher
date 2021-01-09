#!/bin/bash
#
#  name:        informix_entry.sh:
#  description: Starts Informix in Docker container
#




###
###  Override Options passed in by Dockerfile 
###  Override with -E OPTIONS=0x21 on the docker run cmd line.
###

if [ $OPTIONS ]
then
   OPT=$OPTIONS
else
   OPT=$1
fi

###
### Globals - Maybe put into env section  as needed.
###
MONGO_PROP_FILENAME=wl_mongo.properties
REST_PROP_FILENAME=wl_rest.properties
MQTT_PROP_FILENAME=wl_mqtt.properties


function set_env() {

###
###  Setup environment
###
#trap finish_shutdown SIGHUP SIGINT SIGTERM SIGKILL
trap finish_shutdown SIGHUP SIGINT SIGTERM 

###
###  If STORAGE=local, then change storage to in container 
###

ENVFILE=/usr/local/bin/informix_inf.env



## env_STORAGE not read in yet so read it here and adjust
## Storage location accordingly.

if [[ `echo ${STORAGE}|tr /a-z/ /A-Z/` == "LOCAL" ]]
then
   MSGLOG ">>>    Using LOCAL storage! ..." N
   cnt=`grep localdata ${ENVFILE}|wc -l`
   if [[ $cnt = "0" ]];
   then
   MSGLOG ">>>    Ressetting INFORMIX_DATA_DIR ..." N
   SED "s/data/localdata/g" ${ENVFILE} 
   fi
fi



## DBSERVERNAME Not read in yet so read it and adjust
## INFORMIXSERVER accordingly
#cat $ENVFILE
if [[ ! -z $DBSERVERNAME ]] 
then
MSGLOG ">>>    RESETTING INFORMIXSERVER = ${DBSERVERNAME}"
SED "s/INFORMIXSERVER=informix/INFORMIXSERVER=${DBSERVERNAME}/g" ${ENVFILE} 
fi

. $ENVFILE 
#cat $ENVFILE
read_env

}

function read_env() {

env_STORAGE=`echo $STORAGE|tr /a-z/ /A-Z/`
env_SIZE=`echo $SIZE|tr /a-z/ /A-Z/`
env_TYPE=`echo $TYPE|tr /a-z/ /A-Z/`

env_HA=`echo $HA|tr /a-z/ /A-Z/`
env_HA_PRIMARY=`echo $HA_PRIMARY`
env_HA_PRI_DBSERVERNAME=`echo $HA_PRI_DBSERVERNAME`
env_HQSERVER=`echo $HQSERVER`
env_HQAGENT=`echo $HQAGENT|tr /a-z/ /A-Z/`
env_HQSETUP=`echo $HQSETUP|tr /a-z/ /A-Z/`
env_HQSERVER_MAPPED_HTTP_PORT=`echo $HQSERVER_MAPPED_HTTP_PORT`
env_HQSERVER_MAPPED_HOSTNAME=`echo $HQSERVER_MAPPED_HOSTNAME`
env_HQADMIN_PASSWORD=`echo $HQADMIN_PASSWORD`
env_INFORMIX_PASSWORD=`echo $INFORMIX_PASSWORD`
env_DBA_USER=`echo $DBA_USER`
env_DBA_PASSWORD=`echo $DBA_PASSWORD`
env_DBSERVERNAME=`echo $DBSERVERNAME`

[[ -z $env_DBSERVERNAMAE ]] && DEF_INIT_FILENAME="sch_init_informix.sql"  || DEF_INIT_FILENAME="sch_init_${env_DBSERVERNAME}_.sql"

env_MAPPED_HOSTNAME=`echo $MAPPED_HOSTNAME`
env_MAPPED_SQLI_PORT=`echo $MAPPED_SQLI_PORT`

env_LICENSE=`echo $LICENSE|tr /a-z/ /A-Z/`
env_LICENSE_SERVER=`echo $LICENSE_SERVER`
env_ONCONFIG_FILE=`echo $ONCONFIG_FILE`
env_SQLHOSTS_FILE=`echo $SQLHOSTS_FILE`
env_REST_PROP_FILE=`echo $REST_PROP_FILE`
env_MONGO_PROP_FILE=`echo $MONGO_PROP_FILE`
env_MQTT_PROP_FILE=`echo $MQTT_PROP_FILE`
env_INIT_FILE=`echo $INIT_FILE`
env_CONFIGURE_INIT=`echo $CONFIGURE_INIT`
env_RUN_FILE_PRE_INIT=`echo $RUN_FILE_PRE_INIT`
env_RUN_FILE_POST_INIT=`echo $RUN_FILE_POST_INIT`


env_PORT_DRDA=`echo $PORT_DRDA|tr /a-z/ /A-Z/`
env_PORT_REST=`echo $PORT_REST|tr /a-z/ /A-Z/`
env_PORT_MONGO=`echo $PORT_MONGO|tr /a-z/ /A-Z/`
env_PORT_MQTT=`echo $PORT_MQTT|tr /a-z/ /A-Z/`

env_BUFFERS_PERCENTAGE=`echo $BUFFERS_PERCENTAGE`
env_SHMVIRT_PERCENTAGE=`echo $SHMVIRT_PERCENTAGE`
env_NONPDQ_PERCENTAGE=`echo $NONPDQ_PERCENTAGE`


## HANDLE env defaults
##
[[ $env_PORT_DRDA != "OFF" ]] && env_PORT_DRDA="ON"
[[ $env_PORT_REST != "OFF" ]] && env_PORT_REST="ON"
[[ $env_PORT_MONGO != "OFF" ]] && env_PORT_MONGO="ON"
[[ $env_PORT_MQTT != "OFF" ]] && env_PORT_MQTT="ON"


[[ -z $env_INFORMIX_PASSWORD ]] && env_INFORMIX_PASSWORD="in4mix" || sudo sh -c "echo 'informix:${env_INFORMIX_PASSWORD}' | chpasswd"
[[ -z $env_HQADMIN_PASSWORD ]] && env_HQADMIN_PASSWORD="Passw0rd" 

### Add DBA_USER
if ( $(isEnvSet $env_DBA_USER) )
then
   MSGLOG ">>>    Adding User ${env_DBA_USER} ..." N
   sudo sh -c "useradd -m ${env_DBA_USER} -s /bin/bash" 
   if ( $(isEnvSet $env_DBA_PASSWORD) )
   then
      MSGLOG ">>>    ${env_DBA_USER}:${env_DBA_PASSWORD} ..." N
      sudo sh -c "echo '${env_DBA_USER}:${env_DBA_PASSWORD}' | chpasswd"
   else
      MSGLOG ">>>    ${env_DBA_USER}:in4mix ..." N
      sudo sh -c "echo '${env_DBA_USER}:in4mix' | chpasswd"
   fi
fi



 if [[ `echo ${env_HQSERVER}|tr /a-z/ /A-Z/` = "START" ]]
 then
   [[ -z $env_HQSERVER_MAPPED_HOSTNAME ]] && env_HQSERVER_MAPPED_HOSTNAME=`hostname`
 else
   [[ -z $env_HQSERVER_MAPPED_HOSTNAME ]] && env_HQSERVER_MAPPED_HOSTNAME=${env_HQSERVER}
 fi

[[ -z $env_TYPE ]] && env_TYPE="OLTP"
if [[ -z $env_SIZE ]]
then
  if (isDE || isIE) 
  then
     env_SIZE="SMALL"
  else
     env_SIZE="MEDIUM"
  fi
fi



if [[ ! -z $env_BUFFERS_PERCENTAGE && ! -z $env_SHMVIRT_PERCENTAGE && ! -z $env_NONPDQ_PERCENTAGE ]]
then
   if [[ $env_TYPE = "OLTP" ]]
   then
      env_BUFFERS_PERCENTAGE=80
      env_SHMVIRT_PERCENTAGE=19
      env_NONPDQ_PERCENTAGE=1
   fi 
   if [[ $env_TYPE = "DSS" ]]
   then
      env_BUFFERS_PERCENTAGE=20
      env_SHMVIRT_PERCENTAGE=75
      env_NONPDQ_PERCENTAGE=5
   fi 
   if [[ $env_TYPE = "HYBRID" ]]
   then
      env_BUFFERS_PERCENTAGE=50
      env_SHMVIRT_PERCENTAGE=49
      env_NONPDQ_PERCENTAGE=1
   fi 
fi


[[ -z $env_HQSERVER_MAPPED_HTTP_PORT ]] && env_HQSERVER_MAPPED_HTTP_PORT="8080" 

[[ -z $env_MAPPED_SQLI_PORT ]] && env_MAPPED_SQLI_PORT="9088" 
[[ -z $env_MAPPED_HOSTNAME ]] && env_MAPPED_HOSTNAME=`hostname` 



MSGLOG ">>>    LICENSE: ${env_LICENSE}" N 
MSGLOG ">>>    LICENSE_SERVER: ${env_LICENSE_SERVER}" N 
MSGLOG ">>>    INFORMIX_PASSWORD: ${env_INFORMIX_PASSWORD}" N
MSGLOG ">>>    DBA_USER: ${env_DBA_USER}" N
MSGLOG ">>>    DBA_PASSWORD: ${env_DBA_PASSWORD}" N
MSGLOG ">>>    INFORMIX_PASSWORD: ${env_INFORMIX_PASSWORD}" N
MSGLOG ">>>    HQADMIN_PASSWORD: ${env_HQADMIN_PASSWORD}" N 
MSGLOG ">>>    SIZE: ${env_SIZE}" N 
MSGLOG ">>>    TYPE: ${env_TYPE}" N 
MSGLOG ">>>    STORAGE: ${env_STORAGE}" N 
MSGLOG ">>>    BUFFERS_PERCENTAGE: ${env_BUFFERS_PERCENTAGE}" N 
MSGLOG ">>>    SHMVIRT_PERCENTAGE: ${env_SHMVIRT_PERCENTAGE}" N 
MSGLOG ">>>    NONPDQ_PERCENTAGE: ${env_NONPDQ_PERCENTAGE}" N 
MSGLOG ">>>" N
MSGLOG ">>>    MAPPED_HOSTNAME: ${env_MAPPED_HOSTNAME}" N
MSGLOG ">>>    MAPPED_SQLI_PORT: ${env_MAPPED_SQLI_PORT}" N
MSGLOG ">>>" N
MSGLOG ">>>    ONCONFIG_FILE: ${env_ONCONFIG_FILE}" N
MSGLOG ">>>    SQLHOSTS_FILE: ${env_SQLHOSTS_FILE}" N
MSGLOG ">>>    REST_PROP_FILE: ${env_REST_PROP_FILE}" N
MSGLOG ">>>    MONGO_PROP_FILE: ${env_MONGO_PROP_FILE}" N
MSGLOG ">>>    MQTT_PROP_FILE: ${env_MQTT_PROP_FILE}" N
MSGLOG ">>>    DBSERVERNAME: ${env_DBSERVERNAME}" N
MSGLOG ">>>    INIT_FILE: ${env_INIT_FILE}" N
MSGLOG ">>>    RUN_FILE_PRE_INIT: ${env_RUN_FILE_PRE_INIT}" N
MSGLOG ">>>    RUN_FILE_POST_INIT: ${env_RUN_FILE_POST_INIT}" N
MSGLOG ">>>    CONFIGURE_INIT: ${env_CONFIGURE_INIT}" N
MSGLOG ">>>" N 
MSGLOG ">>>    PORT_DRDA: ${env_PORT_DRDA}" N
MSGLOG ">>>    PORT_REST: ${env_PORT_REST}" N
MSGLOG ">>>    PORT_MONGO: ${env_PORT_MONGO}" N
MSGLOG ">>>    PORT_MQTT: ${env_PORT_MQTT}" N
MSGLOG ">>>" N
MSGLOG ">>>    HA: ${env_HA}" N
MSGLOG ">>>    HA_PRIMARY: ${env_HA_PRIMARY}" N
MSGLOG ">>>    HA_PRI_DBSERVERNAME: ${env_HA_PRI_DBSERVERNAME}" N
MSGLOG ">>>    HQSERVER: ${env_HQSERVER}" N
MSGLOG ">>>    HQAGENT: ${env_HQAGENT}" N
MSGLOG ">>>    HQSETUP: ${env_HQSETUP}" N
MSGLOG ">>>    HQSERVER_MAPPED_HOSTNAME: ${env_HQSERVER_MAPPED_HOSTNAME}" N
MSGLOG ">>>    HQSERVER_MAPPED_HTTP_PORT: ${env_HQSERVER_MAPPED_HTTP_PORT}" N 
MSGLOG ">>>" N


}


main()
{

set_env




dt=`date`
MSGLOG ">>>    Starting container/image ($dt) ..." N

###
###  Check LICENSE 
###
if (! isLicenseAccepted)  
then
   MSGLOG ">>>    License was not accepted Exiting! ..." N
   exit
fi

###
###  Check $INFORMIX_CONFIG_DIR - If mounted must have read write access for all 
###
touch $INFORMIX_CONFIG_DIR/tmpfile
if [[ $? != "0" ]]
then
   MSGLOG ">>>    Config MOUNT directory needs 777 permissions. Exiting!  ..." N
   exit
fi
rm $INFORMIX_CONFIG_DIR/tmpfile

###
### Run CONFIGURE_INIT shell script 
### 
if [[ ! -z $env_CONFIGURE_INIT ]]
then
   trap exit SIGHUP SIGINT SIGTERM SIGKILL
   if [[ `echo ${env_CONFIGURE_INIT}|tr /a-z/ /A-Z/` != "NO" ]]  
   then
      MSGLOG ">>>    Running CONFIGURE INIT script $env_CONFIGURE_INIT ..." N
      if ( ifFileExists $INFORMIX_FILES_DIR/$env_CONFIGURE_INIT )
      then
         sudo chmod 777 $INFORMIX_FILES_DIR/$env_CONFIGURE_INIT
         . $INFORMIX_FILES_DIR/$env_CONFIGURE_INIT
      else
         sudo chmod 777 $INFORMIX_CONFIG_DIR/$env_CONFIGURE_INIT
         . $INFORMIX_CONFIG_DIR/$env_CONFIGURE_INIT
      fi
   else
      MSGLOG ">>>    NOT Configuring System ..." N
      sudo cp $SCRIPTS/informix_entry_basic.sh $SCRIPTS/informix_entry.sh
   fi
   wait $!
   exit
fi


### Starting Installed Services
###

SERVICE_LIST="ssh nscd"
###
###  Starting ssh
###
for i in $SERVICE_LIST
do
   cnt=`sudo service $i status|wc -l`
   if [[ $cnt != "0" ]];
   then
      MSGLOG ">>>    SERVICE $i Installed Starting service ..." N
      sudo service $i start
   fi
done



###
### Post Processing to container:
###    Add env script to ~informix/.bashrc
###    Add env script to /root/.profile
###    Install gskit 
### 
if (isNotInitialized)  
then
   printf "\n" >> ~informix/.bashrc
   printf ". $BASEDIR/scripts/informix_inf.env\n" >> ~informix/.bashrc 

   sudo sh -c 'echo "" >> /root/.profile'
   sudo sh -c 'echo ". /usr/local/bin/informix_inf.env" >> /root/.profile'

   MSGLOG ">>>    Installing GSKIT! ..." N
   sudo $INFORMIXDIR/gskit/installgskit
   
else
   cnt=`grep informix_inf ~informix/.bashrc|wc -l`
   if [[ $cnt = "0" ]];
   then
      printf "\n" >> ~informix/.bashrc
      printf ". $BASEDIR/scripts/informix_inf.env\n" >> ~informix/.bashrc 
      sudo sh -c 'echo "" >> /root/.profile'
      sudo sh -c 'echo ". /usr/local/bin/informix_inf.env" >> /root/.profile'


      #sudo $INFORMIXDIR/gskit/installgskit
      #sudo touch /etc/hosts.equiv
      #sudo sh -c "printf '++\n' >> /etc/hosts.equiv"
   fi
fi


###
### Setup INFORMIX_DATA_DIR 
### 
if (isNotInitialized)
then
   MSGLOG ">>>    Create data dirs ..." N
   MSGLOG ">>>        [$INFORMIX_DATA_DIR]" N
   . $SCRIPTS/informix_setup_datadir.sh
   MSGLOG "       [COMPLETED]" N
fi

###
### Setup sqlhosts file
### 
# if (isNotInitialized)
# then
   MSGLOG ">>>    Create sqlhosts file ..." N
   MSGLOG ">>>        [$INFORMIXSQLHOSTS]"  N
   . $SCRIPTS/informix_setup_sqlhosts.sh
# fi
MSGLOG "       [COMPLETED]" N 


###
### Setup $ONCONFIG file
### 
# if (isNotInitialized)
# then
   MSGLOG ">>>    Create ONCONFIG file ..."  N
   MSGLOG ">>>        [$INFORMIXDIR/etc/$ONCONFIG]" N  
   . $SCRIPTS/informix_setup_onconfig.sh $OPT
   MSGLOG "       [COMPLETED]" N 
# fi

###
### Setup sch_init_xxxxxxx.sql script 
### 
if (isNotInitialized)
then
   MSGLOG ">>>    Setting $DEF_INIT_FILENAME file ..."  N

   if [[ $env_SIZE == "SMALL" ]]
   then
    MSGLOG ">>>        Using Small $DEF_INIT_FILENAME" N
      cp $BASEDIR/sql/sch_init_informix.small.sql $INFORMIXDIR/etc/sysadmin/$DEF_INIT_FILENAME
   elif [[ $env_SIZE == "MEDIUM" ]]
   then
    MSGLOG ">>>        Using Medium $DEF_INIT_FILENAME" N
      cp $BASEDIR/sql/sch_init_informix.medium.sql $INFORMIXDIR/etc/sysadmin/$DEF_INIT_FILENAME
   elif [[ $env_SIZE == "LARGE" ]]
   then
    MSGLOG ">>>        Using Large $DEF_INIT_FILENAME" N
      cp $BASEDIR/sql/sch_init_informix.large.sql $INFORMIXDIR/etc/sysadmin/$DEF_INIT_FILENAME 
   elif [[ $env_SIZE == "CUSTOM" ]]
   then
    MSGLOG ">>>        Using custom $DEF_INIT_FILENAME" N
      cp $INFORMIX_CONFIG_DIR/sch_init_informix.custom.sql $INFORMIXDIR/etc/sysadmin/$DEF_INIT_FILENAME
   fi

   if ( $(isEnvSet $env_INIT_FILE) )
   then
      MSGLOG ">>>        Using $env_INIT_FILE supplied by user" N
      if ( ifFileExists $INFORMIX_FILES_DIR/$env_INIT_FILE )
      then
         cp $INFORMIX_FILES_DIR/$env_INIT_FILE $INFORMIXDIR/etc/sysadmin/$DEF_INIT_FILENAME 
      else
         cp $INFORMIX_CONFIG_DIR/$env_INIT_FILE $INFORMIXDIR/etc/sysadmin/$DEF_INIT_FILENAME 
      fi
   else
      if ( ifFileExists $INFORMIX_CONFIG_DIR/$DEF_INIT_FILENAME)
      then
         MSGLOG ">>>        Using $env_INIT_FILE supplied by user" N
         cp $INFORMIX_CONFIG_DIR/$DEF_INIT_FILENAME $INFORMIXDIR/etc/sysadmin/$DEF_INIT_FILENAME
      elif ( ifFileExists $INFORMIX_FILES_DIR/$DEF_INIT_FILENAME)
      then
         MSGLOG ">>>        Using $env_INIT_FILE supplied by user" N
         cp $INFORMIX_FILES_DIR/$DEF_INIT_FILENAME $INFORMIXDIR/etc/sysadmin/$DEF_INIT_FILENAME
      fi
   fi


   MSGLOG "       [COMPLETED]" N 
fi


###
### Update $HOSTNAME in various file(s) 
### 

MSGLOG ">>>    Updating HOSTNAME in file(s)..." N
MSGLOG ">>>        [$INFORMIXSQLHOSTS]"  N
. $SCRIPTS/informix_update_hostname.sh
MSGLOG "       [COMPLETED]" N 


###
### Setup MSGPATH 
### 
if (isNotInitialized)
then
   MSGLOG ">>>    Create MSGPATH file ..." N
   MSGLOG ">>>        [$INFORMIX_DATA_DIR/logs/online.log]" N
   . $SCRIPTS/informix_setup_msgpath.sh
   MSGLOG "       [COMPLETED]" N 
fi


###
### Setup rootdbs 
### 
if (isNotInitialized)
then
   MSGLOG ">>>    Create rootdbs ..." N
   MSGLOG ">>>        [$INFORMIX_DATA_DIR/spaces/rootdbs.000]" N
   . $SCRIPTS/informix_setup_rootdbs.sh
   MSGLOG "       [COMPLETED]" N
fi

###
### Run RUN_FILE_PRE_INIT shell script 
### 
if [[ ! -z $env_RUN_FILE_PRE_INIT ]]
then
   if (isNotInitialized)
   then
   MSGLOG ">>>    Running PRE INIT FILE $env_RUN_FILE_PRE_INIT ..." N
      if ( ifFileExists $INFORMIX_FILES_DIR/$env_RUN_FILE_PRE_INIT )
      then
         sudo chmod 777 $INFORMIX_FILES_DIR/$env_RUN_FILE_PRE_INIT
         . $INFORMIX_FILES_DIR/$env_RUN_FILE_PRE_INIT 
      else
         sudo chmod 777 $INFORMIX_CONFIG_DIR/$env_RUN_FILE_PRE_INIT
         . $INFORMIX_CONFIG_DIR/$env_RUN_FILE_PRE_INIT 
      fi
   fi
fi

###
### Run informix_custom_install.sh 
### 
if [ -e $SCRIPTS/informix_custom_install.sh ];
then
   MSGLOG ">>>    Running informix_custom_install.sh..." N
   . $SCRIPTS/informix_custom_install.sh
fi



###
### Initialize Instance - First time initialize disk space 
### 
if (isNotInitialized)
then
   MSGLOG ">>>    Informix DISK Initialization ..." N
   . $SCRIPTS/informix_init.sh
else
   MSGLOG ">>>    Informix SHM Initialization ..." N
   . $SCRIPTS/informix_online.sh
fi
MSGLOG "       [COMPLETED]" N


###
### Run RUN_FILE_POST_INIT shell script 
### 
# if [[ ! -z $env_RUN_FILE_POST_INIT ]]
# then
#    if (isNotInitialized)
#    then
#       MSGLOG ">>>    Running POST INIT FILE $env_RUN_FILE_POST_INIT ..." N
#       if ( ifFileExists $INFORMIX_FILES_DIR/$env_RUN_FILE_POST_INIT )
#       then
#          MSGLOG ">>>    $INFORMIX_FILES_DIR/$env_RUN_FILE_POST_INIT ..." N
#          sudo chmod 777 $INFORMIX_FILES_DIR/$env_RUN_FILE_POST_INIT
#          . $INFORMIX_FILES_DIR/$env_RUN_FILE_POST_INIT 
#       else
#          MSGLOG ">>>    $INFORMIX_CONFIG_DIR/$env_RUN_FILE_POST_INIT ..." N
#          sudo chmod 777 $INFORMIX_CONFIG_DIR/$env_RUN_FILE_POST_INIT
#          . $INFORMIX_CONFIG_DIR/$env_RUN_FILE_POST_INIT 
#       fi
#    fi
# fi

pwd

###
### Setup Wire Listeners  - 
### 
MSGLOG ">>>    Setting up WL! ..." N
. $SCRIPTS/informix_wl.sh $OPT

###
### Setup HQ Server  
### 
if [[ `echo ${env_HQSERVER}|tr /a-z/ /A-Z/` = "START" ]]
then
   MSGLOG ">>>    Setting up HQ Server! ..." N
   . $SCRIPTS/informix_setup_hqserver.sh
fi

###
### Setup HQ Agent 
### 
#if [[ `echo ${env_HQAGENT}|tr /a-z/ /A-Z/` = "START" ]]
if [[ `echo ${env_HQAGENT}|tr /a-z/ /A-Z/` = "START" ]] || [[ `echo ${env_HQAGENT}|tr /a-z/ /A-Z/` = "ADMIN" ]] 
then
   MSGLOG ">>>    Setting up HQ Agent! ..." N
   . $SCRIPTS/informix_setup_hqagent.sh 
fi

###
### Setup HQ (monitoring, dashboards) 
### 
if ( $(isEnvSet $env_HQSETUP) )
then
   MSGLOG ">>>    Setting up HQ Agent! ..." N
   . $SCRIPTS/informix_setup_hqsetup.sh 
fi

###
### Setup HA  (PRI, SEC, RSS)
### 
if [[ ! -z $env_HA ]] 
then
   MSGLOG ">>>    Setting up HA! ..." N
   . $SCRIPTS/informix_setup_ha.sh 
fi


###
### Run RUN_FILE_POST_INIT shell script 
### 
if [[ ! -z $env_RUN_FILE_POST_INIT ]]
then
   if (isNotInitialized)
   then
      MSGLOG ">>>    Running POST INIT FILE $env_RUN_FILE_POST_INIT ..." N
      if ( ifFileExists $INFORMIX_FILES_DIR/$env_RUN_FILE_POST_INIT )
      then
         MSGLOG ">>>    $INFORMIX_FILES_DIR/$env_RUN_FILE_POST_INIT ..." N
         sudo chmod 777 $INFORMIX_FILES_DIR/$env_RUN_FILE_POST_INIT
         . $INFORMIX_FILES_DIR/$env_RUN_FILE_POST_INIT 
      else
         MSGLOG ">>>    $INFORMIX_CONFIG_DIR/$env_RUN_FILE_POST_INIT ..." N
         sudo chmod 777 $INFORMIX_CONFIG_DIR/$env_RUN_FILE_POST_INIT
         . $INFORMIX_CONFIG_DIR/$env_RUN_FILE_POST_INIT 
      fi
   fi
fi


###
### Execute the init.d scripts 
### 
exec_S_initdb

###
### Set $INFORMIX_DATA_DIR/.initialized
### 
if (isNotInitialized);
then
   touch $INFORMIX_DATA_DIR/.initialized
fi

./informix.sh

printf "boo\n"|tee -a $INIT_LOG
printf "\n"|tee -a $INIT_LOG
printf "\t###############################################\n"|tee -a $INIT_LOG
printf "\t# Informix container login Information:        \n"|tee -a $INIT_LOG
printf "\t#   user:            informix                  \n"|tee -a $INIT_LOG
printf "\t#   password:        $DB_PASS                  \n"|tee -a $INIT_LOG
printf "\t###############################################\n"|tee -a $INIT_LOG
printf "\n"


### run interactive shell now it is done in Dockerfile
printf "###    Type exit to quit the Startup Shell\n"|tee -a $INIT_LOG
printf "###       This will stop the container\n" |tee -a $INIT_LOG
printf "\n"|tee -a $INIT_LOG
printf "###    For interactive shell run:\n"|tee -a $INIT_LOG
printf "###      docker exec -it ${HOSTNAME} bash\n"|tee -a $INIT_LOG
printf "\n"|tee -a $INIT_LOG
printf "###    To start the container run:\n"|tee -a $INIT_LOG
printf "###      docker start ${HOSTNAME} \n"|tee -a $INIT_LOG
printf "\n"|tee -a $INIT_LOG
printf "###    To safely shutdown the container run:\n"|tee -a $INIT_LOG
printf "###      docker stop ${HOSTNAME} \n"|tee -a $INIT_LOG
printf "\n"|tee -a $INIT_LOG


finish_org
finish_shutdown

}



#####################################################################
### FUNCTION DEFINITIONS
#####################################################################

SUCCESS=0
#FAILURE=-1
FAILURE=1

###
### isEnvNotSet
###

function ifFileExists()
{
if [[ -f $1 ]]
then
   return $SUCCESS
else 
   return $FAILURE
fi
}

function ifFileNotExists()
{
if [[ -f $1 ]]
then
   return $FAILURE
else 
   return $SUCCESS
fi
}

function isEnvNotSet()
{
if [[ -z $1 ]]
then
   return $SUCCESS
else 
   return $FAILURE
fi
}

function isEnvSet()
{
if [[ -z $1 ]]
then
   return $FAILURE
else 
   return $SUCCESS
fi
}


###
### exec_S_initdb 
###
function exec_S_initdb()
{
MSGLOG ">>>    Execute init-startup scripts" N

if [ -d $INFORMIX_DATA_DIR/init.d ]
then
   filelist=`ls -x $INFORMIX_DATA_DIR/init.d/S*`
   for f in $filelist
   do
   MSGLOG ">>>        File: $f" N
   done
fi
MSGLOG "       [COMPLETED]" N
}


###
### exec_K_initdb 
###
function exec_K_initdb()
{
MSGLOG ">>>    Execute init-shutdown scripts" N

if [ -d $INFORMIX_DATA_DIR/init.d ]
then
   filelist=`ls -x $INFORMIX_DATA_DIR/init.d/K*`
   for f in $filelist
   do
   MSGLOG ">>>        File: $f" N
   done
fi
MSGLOG "       [COMPLETED]" N
}




function isLicenseAccepted()
{
#env_LICENSE=`echo $LICENSE|tr /a-z/ /A-Z/`
if [[ $env_LICENSE = "ACCEPT" ]];
then
   return $SUCCESS
else
   return $FAILURE 
fi
}



###
### isDE
###
function isDE()
{
wc=`oninit -version|grep 'Build Version'|grep DE|wc -l`
[ $wc = "1" ] && return $SUCCESS || return $FAILURE
}

###
### isIE
###
function isIE()
{
wc=`oninit -version|grep 'Build Version'|grep IE|wc -l`
[ $wc = "1" ] && return $SUCCESS || return $FAILURE
}



###
### isNotInitialized 
###
function isNotInitialized()
{
dt=`date`
if [ ! -e $INFORMIX_DATA_DIR/.initialized ];
then
   MSGLOG ">>>    DISK INITIALIZING ($dt) ..." N 
   return $SUCCESS
else
   MSGLOG ">>>    DISK ALREADY INITIALIZED ($dt) ..." N 
   return $FAILURE 
fi
}


###
### HQLOG
###

function HQLOG() {
   printf "%s\n" "$1" >> $INFORMIXDIR/hq/hq.log
   MSGLOG "$1" N 
}

###
### MSGLOG 
###
function MSGLOG()
{

if [ ! -e $INIT_LOG ]
then
   touch $INIT_LOG
fi

if [[ $2 = "N" ]]
then
   [[ ! -z $INIT_LOG ]] && printf "%s\n" "$1" >> $INIT_LOG
   echo "$1" >&2
else
   #printf "%s" "$1" |tee -a $INIT_LOG
   [[ ! -z $INIT_LOG ]] && printf "%s\n" "$1" >> $INIT_LOG
   echo "$1" >&2
fi
}

function SED()
{
[[ `echo $3|tr /a-z/ /A-Z/` == "Y" ]] && MSGLOG  ">>>    SED $1 $2"
sudo sed -i --follow-symlinks "$1" "$2"
}

function RUNAS()
{
USER=$1
CMD=$2
MSGLOG ">>>    RUNAS: $1  $2"
sudo -u $1 sh -c ". $ENVFILE && $2"
}



function finish_org()
{
#trap finish_shutdown SIGHUP SIGINT SIGTERM SIGKILL
trap finish_shutdown SIGHUP SIGINT SIGTERM 
tail -f  $INFORMIX_DATA_DIR/logs/online.log
wait $!

}

function finish_shutdown()
{
MSGLOG ">>> " N
MSGLOG ">>>    SIGNAL received - Shutdown (finish_shutdown):" N
MSGLOG ">>> " N
. $BASEDIR/scripts/informix_stop.sh
}

###
### Function waitForSysadmin
###    Wait for sysadmin database to exist
###
function getDomain() {
NAME=$1
domain=`ping -c 1 ${NAME}|grep icmp `
MSGLOG ">>>  GETDOMAIN: $domain"
domain=`ping -c 1 ${NAME}|grep icmp |awk '{print $4}' `
MSGLOG ">>>  GETDOMAIN: $domain"
domain=`ping -c 1 ${NAME}|grep icmp |awk '{print $4}' | cut -d '.' -f2 `
MSGLOG ">>>  GETDOMAIN: $domain"
echo $domain
}

###
### 
### 
function waitForHAWL() {
while true
do  
### What is best host here ??  $HOSTNAME ??   

   DB=`curl http://${env_HA_PRIMARY}:27018/sysmaster/sysdatabases 2>/dev/null|jq '.[] |select(.name=="sysmaster") | .name' | sed -e 's/"//g' `
   if [[ $DB == "sysmaster" ]]
   then
      MSGLOG ">>> Wire Listener Available."
      return
   else
      MSGLOG ">>> Wire Listener NOT Available yet."
      sleep 5
   fi
done
}


###
### 
### 
function waitForWL() {
while true
do  
   DB=`curl http://${HOSTNAME}:27018/sysmaster/sysdatabases 2>/dev/null|jq '.[] |select(.name=="sysmaster") | .name' | sed -e 's/"//g' `
   if [[ $DB == "sysmaster" ]]
   then
      MSGLOG ">>> Wire Listener Available."
      return
   else
      MSGLOG ">>> Wire Listener NOT Available yet."
      sleep 5
   fi
done
}

###
### Function waitForSysadmin
###    Wait for sysadmin database to exist
###
function waitForSysadmin() {
while true
do  
   cnt=`echo "select count(*) from sysdatabases where name='sysadmin' "| dbaccess sysmaster - |grep -v count|tr -d ' \n'`
   if [[ $cnt == "1" ]]
   then
      break
   else
      sleep 1
   fi
done
}


###
### Function waitForSysadmin
###    Wait for sysadmin database to exist
###
function waitForRemoteSQLI() {
REMOTE_SERVER=$1
while true 
do
   cnt=`curl http://${REMOTE_SERVER}:9088 2>&1|grep Empty|wc -l `
   if [[ $cnt == "1" ]]
   then
      break
   else
      sleep 1
   fi

done
}




function waitForHQSERVER() {

MSGLOG "DEBUG: HQSERVER_MAPPED_HOSTNAME: ${env_HQSERVER_MAPPED_HOSTNAME}" 
MSGLOG "DEBUG: HQSERVER_MAPPED_HTTP_PORT: ${env_HQSERVER_MAPPED_HTTP_PORT}" 
while true
do   
   CNT=`curl http://${env_HQSERVER_MAPPED_HOSTNAME}:${env_HQSERVER_MAPPED_HTTP_PORT} 2>/dev/null|grep InformixHQ |wc -l`
MSGLOG "DEBUG: CNT: ${CNT}" 
   if [[ $CNT != "0" ]]
   then
      MSGLOG ">>> HQServer Available."
      return
   else
      MSGLOG ">>> HQServer NOT Available yet."
      sleep 5
   fi
done
}





###
###  Call to main
###
main "$@"

