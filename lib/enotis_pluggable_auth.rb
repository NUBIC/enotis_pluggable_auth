require 'enotis_pluggable_auth/version'
require 'date'
require 'yaml'
require 'rubygems'
require 'json'
require 'faraday'
require 'cachetastic'

module EnotisPluggableAuth
  class EnotisAuthority < Cachetastic::Cache
    cache_log = Logger.new("logs/cachetastic.log") # must be specified, because the default log tries to write to a folder that doesn't exist
    cache_log.level = Logger::ERROR
    configatron.cachetastic.defaults.logger = [cache_log]
    
    configatron.cachetastic.defaults.default_expiry = 1200  # 20 minutes
    configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::LocalMemory
    
    
    CONFIG = YAML.load_file("/etc/nubic/psc_enotis_pluggable_auth.yml")
  
    def enotis_faraday_connection
      Faraday::Connection.new(:url => CONFIG["host"], :ssl => {:ca_file => CONFIG['ca_file']})
    end
  
    def get_user_by_username(username, level)
      get_user(username)
    end

    def get_user_by_id(id, level)
      get_user(id)
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
      def get_user(username_or_id)
        cached_result = check_cache_for(username_or_id)
        
        cached_result ? cached_result : get_and_cache_fresh_result_from_enotis(username_or_id)
      end
      
      def get_and_cache_fresh_result_from_enotis(username_or_id)
        enotis_response = JSON.parse(enotis_faraday_connection.get("#{CONFIG['users']}/#{username_or_id}.json").body, {:symbolize_names => true})  
        auth_hash = build_authorization_hash(enotis_response)
        
        # Store both by username, and by id, so the cache can look it up by either value
        EnotisAuthority.set(auth_hash[:username], auth_hash)
        EnotisAuthority.set(auth_hash[:id], auth_hash)
      end
      
      def check_cache_for(username_or_id)
        EnotisAuthority.get(username_or_id)
      end
          
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
