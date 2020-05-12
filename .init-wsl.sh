#!/bin/sh

sudo /usr/sbin/service rsyslog start
sudo /usr/sbin/service cron start
sudo /usr/sbin/service anacron start
sudo /usr/sbin/service dbus start
