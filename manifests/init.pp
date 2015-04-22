# Class: cabot
#
# This module manages Arachnys Cabot
#
# Parameters:
# TODO
#
# Requires: see Modulefile
#
# Sample Usage:
#
class cabot (
  # TODO

  # PostgreSQL
  $install_postgres       = false,
  $install_postgres_devel = true,
  $setup_db               = true,
  $db_database            = 'cabot',
  $db_username            = 'cabot',
  $db_password            = 'cabot',

  # Install
  $install_gcc    = true,
  $install_git    = false,
  $install_ruby   = false,
  $install_python = false,
  $install_nodejs = false,

  # Redis
  $install_redis  = false,


) inherits cabot::params {
  # Sub-classes
  contain cabot::postgres
  contain cabot::install
  contain cabot::configure
  contain cabot::redis
  contain cabot::webserver

  # Dependency Chain
  Class['cabot::postgres']
  ->
  Class['cabot::install']
  ->
  Class['cabot::configure']
  ->
  Class['cabot::redis']
  ->
  Class['cabot::webserver']
}
