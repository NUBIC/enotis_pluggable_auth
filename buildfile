require 'buildr/bnd'
require 'buildr-gemjar'

define 'enotis-pluggable-auth' do
  project.version = '0.0.4.DEV'
  package(:gemjar).with_gem(:file => _('enotis_pluggable_auth-0.0.4.gem'))
end
