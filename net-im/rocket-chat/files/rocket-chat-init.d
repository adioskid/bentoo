#!/sbin/openrc-run
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

command="/usr/share/rocket-chat/node/n/versions/node/$(ls /usr/share/rocket-chat/node/n/versions/node)/bin/node"
command_args="/usr/share/rocket-chat/main.js"
start_stop_daemon_args="-u ${ROCKET_USER:=rocket} \
			-g ${ROCKET_GROUP:=daemon} \
			-1 ${ROCKET_LOG_APP:-${ROCKET_LOG:-/var/log/rocket-chat}/app.log} \
			-2 ${ROCKET_LOG_ERR:-${ROCKET_LOG:-/var/log/rocket-chat}/err.log} \
			-e \"MONGO_URL=${ROCKET_MONGO_URL:-mongodb://localhost:27017/rocketchat}\" \
			-e \"MONGO_OPLOG_URL=${ROCKET_MONGO_OPLOG_URL:-mongodb://localhost:27017/local}\" \
			-e \"ROOT_URL=${ROCKET_ROOT_URL}\" \
			-e \"PORT=${ROCKET_PORT:-7331}\" \
			-e \"MAIL_URL=${ROCKET_MAIL_URL}\" \
			-b -m -p ${ROCKET_PID:-/run/rocket-chat.pid}"

start_pre() {
    
    # For a restart, give the node process some time
    # to properly terminate.
    if [ "$RC_CMD" = restart ]; then
	sleep 1 
    fi


    checkpath -d -m 0700 -o "${ROCKET_USER}":"${ROCKET_GROUP}" "/tmp/ufs"
}

depend() {
	need net
}
