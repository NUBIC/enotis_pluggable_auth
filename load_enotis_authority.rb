require 'rubygems'

gemjar = File.join(File.dirname(__FILE__), 'enotis-pluggable-auth-0.0.1.DEV.jar')
fail "gemjar not found" unless File.exist?(gemjar)
require gemjar
require 'enotis_pluggable_auth'
