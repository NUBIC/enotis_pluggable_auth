require 'buildr/bnd'
require 'buildr-gemjar'

define 'enotis-pluggable-auth' do
  project.version = '1.0.0'
  package(:gemjar).with_gem(:file => _('enotis_pluggable_auth-1.0.0.gem'))
end
