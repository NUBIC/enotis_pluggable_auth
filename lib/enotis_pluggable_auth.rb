require "enotis_pluggable_auth/version"
require 'date'
require 'yaml'
require 'rubygems'
require 'json'
require 'faraday'

module EnotisPluggableAuth
  class EnotisAuthority
    CONFIG = YAML.load_file("/etc/nubic/psc_enotis_pluggable_auth.yml")
  
    def enotis_faraday_connection
      Faraday::Connection.new(:url => CONFIG["host"], :ssl => {:ca_file => CONFIG['ca_file']})
    end
  
    def get_user_by_username(username, level)
      enotis_response = JSON.parse(enotis_faraday_connection.get("#{CONFIG['users']}/#{username}.json").body, {:symbolize_names => true})
    
      build_authorization_hash(enotis_response)
    end

    def get_user_by_id(id, level)
      enotis_response = JSON.parse(enotis_faraday_connection.get("#{CONFIG['users']}/#{id}.json").body, {:symbolize_names => true})
    
      build_authorization_hash(enotis_response)
    end

    def get_users_by_role(role_name)
      case role_name
      when "System Administrator", :system_administrator
        enotis_list_of_admins = JSON.parse(enotis_faraday_connection.get("#{CONFIG['admins']}.json").body, {:symbolize_names => true})
          
        authorization_array_response = []
        enotis_list_of_admins.each do |admin|
          authorization_array_response << build_authorization_hash(admin)
        end
        return authorization_array_response
      else
        return nil
      end
    end

    def search_users(criteria)
      return JSON.parse("[]")
    end
  
    private
      def build_authorization_hash(enotis_response)
        auth_hash = {
          :id               => enotis_response[:id],
          :username         => enotis_response[:netid],
          :first_name       => enotis_response[:first_name],
          :last_name        => enotis_response[:last_name],
          :email_address    => enotis_response[:email]
        }
      
        auth_hash[:roles] = map_enotis_roles_to_psc_roles(enotis_response[:roles])
      
        auth_hash
      end
    
      def map_enotis_roles_to_psc_roles(roles_list)
        roles = []
      
        case roles_list.first
        when "admin"
          return {
            :system_administrator => true,                                              # Admin of PSC
            :user_administrator => true,                                                # Add/edit users, can access the user administrator list
            :study_creator => {:sites => true},                                         # Can add studies
            :study_calendar_template_builder => {:sites => true, :studies => true},     # Can create/edit PSC templates
            :subject_manager => {:sites => true},
            :study_subject_calendar_manager => {:sites => true, :studies => true}       # Can add/edit/change the segments that a subject is on
          }
        else
          return { :subject_manager => {:sites => [CONFIG["site_name"]]}, :study_subject_calendar_manager => { :sites => [CONFIG["site_name"]], :studies => roles_list }}
        end
      end
  end
end
