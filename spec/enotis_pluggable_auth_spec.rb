require 'enotis_pluggable_auth'

describe EnotisPluggableAuth::EnotisAuthority do

  CONFIG = YAML.load_file("/etc/nubic/psc_enotis_pluggable_auth.yml")
  $suite_authorization_source = EnotisPluggableAuth::EnotisAuthority.new

  before(:each) do
    @enotis_response_for_admin = "{\"roles\":[\"admin\"],\"first_name\":\"Admin\",\"email\":\"admin@example.com\",\"netid\":\"adm123\",\"last_name\":\"Admin\",\"id\":1}"
    @enotis_response_for_all_admins = "[#{@enotis_response_for_admin}]"
    @psc_auth_hash_for_admin = {
      :id => 1,
      :username => "adm123",
      :first_name => "Admin",
      :last_name => "Admin",
      :email_address => "admin@example.com",
      :account_end_date => (Date.today + 18250),
      :roles => {
        :system_administrator => true,
        :user_administrator => true,
        :study_creator => {:sites => true},
        :study_calendar_template_builder => {:sites => true, :studies => true},
        :study_subject_calendar_manager => {:sites => true, :studies => true}
      }
    }
    
    @psc_auth_array_for_all_admins = [@psc_auth_hash_for_admin]
    
    @enotis_response_for_user = "{\"roles\":[\"STU00011111\",\"STU00022222\",\"STU000333333\"],\"first_name\":\"User\",\"email\":\"user@example.com\",\"netid\":\"usr123\",\"last_name\":\"User\",\"id\":2}"
    @psc_auth_hash_for_user = {
      :id => 2,
      :username => "usr123",
      :first_name => "User",
      :last_name => "User",
      :email_address => "user@example.com",
      :account_end_date => (Date.today + 18250),
      :roles => {
        :study_subject_calendar_manager => { :sites=>[CONFIG['site_name']], :studies=>["STU00011111", "STU00022222", "STU000333333"] }
      }
    }
  end

  it "should properly map an eNOTIS admin user to a set of roles" do
    roles = $suite_authorization_source.send(:map_enotis_roles_to_psc_roles, JSON.parse(@enotis_response_for_admin)["roles"])
    
    roles.should == @psc_auth_hash_for_admin[:roles]
  end
  
  it "should properly map an eNOTIS non-admin user to a set of roles" do
    roles = $suite_authorization_source.send(:map_enotis_roles_to_psc_roles, JSON.parse(@enotis_response_for_user)["roles"])
    
    roles.should == @psc_auth_hash_for_user[:roles]
  end

  it "make a global variable available named $suite_authorization_source" do
    $suite_authorization_source.nil?.should be_false
  end
  
  it "should return a properly formatted hash for an admin when requested by user id" do
    Faraday.default_connection.stub!(:get).and_return(mock(Faraday::Response, :body => @enotis_response_for_admin))

    $suite_authorization_source.get_user_by_id(1, nil).should == @psc_auth_hash_for_admin
  end
  
  it "should return a properly formatted hash for an admin when requested by username" do
    Faraday.default_connection.stub!(:get).and_return(mock(Faraday::Response, :body => @enotis_response_for_admin))
    
    $suite_authorization_source.get_user_by_username("adm123", nil).should == @psc_auth_hash_for_admin
  end

  it "should return a properly formatted hash for a user when requested by user id" do
    Faraday.default_connection.stub!(:get).and_return(mock(Faraday::Response, :body => @enotis_response_for_user))
    
    $suite_authorization_source.get_user_by_id(1, nil).should == @psc_auth_hash_for_user
  end
  
  it "should return a properly formatted hash for a user when requested by username" do
    Faraday.default_connection.stub!(:get).and_return(mock(Faraday::Response, :body => @enotis_response_for_user))
    
    $suite_authorization_source.get_user_by_username("usr123", nil).should == @psc_auth_hash_for_user
  end
  
  it "should return nil when asked for users by role, for any role other than 'system-administrator'" do 
    $suite_authorization_source.get_users_by_role("some role, any role really").should be_nil
  end
  
  it "should return an array of properly formatted hashes of admins when searching for users by the :system_administrator role" do 
    Faraday.default_connection.stub!(:get).and_return(mock(Faraday::Response, :body => @enotis_response_for_all_admins))
    @psc_auth_array_for_all_admins.each do |auth_hash|
      puts auth_hash[:roles].inspect
    end
    $suite_authorization_source.get_users_by_role(:system_administrator).should == @psc_auth_array_for_all_admins
  end
  
  it "should return nil when a search for users is submitted" do
    $suite_authorization_source.search_users("whatever criteria you want to throw in here").should be_nil
  end
  
end
