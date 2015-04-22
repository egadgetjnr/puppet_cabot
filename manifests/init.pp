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
