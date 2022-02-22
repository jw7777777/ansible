#!/bin/bash
#Purpose:  Automate the bounce and clearing of web/app caches for Peoplesoft Finance FSPROD85
#Author:   Jason Wash, City of Kingston



#Set environment for Peoplesoft servers
source /app/psscripts/psconfig_FSPROD.sh

PS_CFG_HOME=$PS_HOME; export PS_CFG_HOME
TUXDIR=$PS_HOME/infrastructure/tuxedo10gR3; export TUXDIR
JROCKIT_HOME=$PS_HOME/infrastructure/jrrt-4.0.1-1.6.0; export JROCKIT_HOME
LD_LIBRARY_PATH=$TUXDIR/lib:$PS_HOME/bin:$JROCKIT_HOME/jre/lib/amd64:$LD_LIBRARY_PATH; export LD_LIBRARY_PATH
PATH=$TUXDIR/bin:$JROCKIT_HOME/jre/lib/amd64:$PATH; export PATH

ORACLE_HOME=/home/oracle/app/oracle/product/11.2.0/client_1; export ORACLE_HOME
PATH=$PATH:$ORACLE_HOME/bin;export PATH
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib;export LD_LIBRARY_PATH

COBDIR=$PS_HOME/infrastructure/mf; export COBDIR
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COBDIR/lib;export LD_LIBRARY_PATH
PATH=$PATH:$COBDIR/bin;export PATH

JAVA_HOME=/app/fs890/pt851/infrastructure/jrrt-4.0.1-1.6.0
export JAVA_HOME
PATH=$PATH:$JAVA_HOME;export PATH

PATH=$PATH:$PSJLIBPATH; export PATH


#Stop the webserver and clear the PIA cache
/app/fs890/pt851/webserv/peoplesoft/bin/stopPIA.sh 2>&1 | tee -a /tmp/bounce.log
/app/fs890/pt851/webserv/peoplesoft/bin/clear_cache.sh 2>&1 | tee -a /tmp/bounce.log

#Stop the application server and clear cache
psadmin -c shutdown! -d FSPROD85 2>&1 | tee -a /tmp/bounce.log
psadmin -c cleanipc -d FSPROD85 2>&1 | tee -a /tmp/bounce.log
psadmin -c purge -d FSPROD85 -noarch -log "Manual Cache Purge" 2>&1 | tee -a /tmp/bounce.log

#Start the application server 
psadmin -c boot -d FSPROD85 2>&1 | tee -a /tmp/bounce.log
psadmin -c sstatus -d FSPROD85 2>&1 | tee -a /tmp/bounce.log

#Start the webserver
/app/fs890/pt851/webserv/peoplesoft/bin/startPIA.sh 2>&1 | tee -a /tmp/bounce.log

#Print log file contents for review in AWX
cat /tmp/bounce.log

#Clean up log for next run
mv /tmp/bounce.log /tmp/bounce.log.bak

#Misc for debugging
#Check that environment set correctly for Peoplesoft
#psadmin -env

#Check that process scheduler is running
#psadmin -p status -d FSPROD85

