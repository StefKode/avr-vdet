#!/bin/bash
# APPTS App Starter Script
# Copyright: Stefan Koch, 2019

############################################################
# USER DEFINITIONS

VERSION=0.1
PACKAGES=vim
ADDGROUP=

############################################################
# INTERNAL DATA

INST_CHECK=$HOME/.installed-$VERSION
TRACE_LOG=$HOME/trace.log

############################################################
# HELPER

function tracelog {
	echo "$(date): $@" >> $TRACE_LOG 
	echo "TRACE: $@"
}

############################################################
# STARTUP PROCESS
cd /home/app/code

if [ ! -e $INST_CHECK ]; then
	rm -f $TRACE_LOG
	tracelog "Init installation.."
fi

#-----------------------------------------------------------
# extend groups if necessary

if [ "$ADDGROUP" != "" ]; then
	if [ "$(id -G -n | grep $ADDGROUP)" = "" ]; then
		tracelog "add missing group"
		if [ "$GROUP_ADDITION" = "" ]; then
			# add group and start new instance
			sudo usermod -a -G $ADDGROUP $USER
			export GROUP_ADDITION=1
			sg $ADDGROUP $(readlink -f $0)
			exit $?
		else
			tracelog "ERROR - group add failed (skipped)"
		fi
	fi
fi

#-----------------------------------------------------------
# One-time Installation

if [ ! -e $INST_CHECK ]; then
	tracelog "Perform installation"
	sudo apt-get update -y
	sudo apt-get install $PACKAGES -y
	tracelog "Installation done"
	touch $INST_CHECK
fi | tee -a $TRACE_LOG

#-----------------------------------------------------------
# App Startup

./run &
