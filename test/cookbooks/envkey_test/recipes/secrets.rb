#
# Cookbook:: envkey_test
# Recipe:: secrets
#

# Get the ENVKEY token for the applcation named 'chef-envkey' from a vault item.
envkey_token = chef_vault_item('envkey', 'keys')[node.policy_group]['chef-envkey']

# Create an application directory
directory '/opt/chef-envkey'

# Fetch all application secrets using the `envkey_source_vars` helper.
credentials = envkey_source_vars(envkey_token)

# Write a single application secret to a file using the credentials hash.
file '/opt/chef-envkey/application.credential' do
  content credentials.fetch('VARIABLE_A')
  mode '0600'
  action :create
end

# Write all application secrets to a file using the `envkey_source_file` helper.
%w(dot-env json pam).each do |out_format|
  envkey_source_file "/opt/chef-envkey/application.#{out_format}" do
    envkey envkey_token
    out_format out_format
    owner 'root'
    group 'root'
    mode '600'
    action :create
  end
end

# Write a single application secret to a file using the `envkey_secret` helper.
file '/opt/chef-envkey/application.secret' do
  extend EnvkeyCookbook::ClientHelpers
  content envkey_secret(name: 'VARIABLE_A', service: :envkey, config: { 'envkey' => envkey_token })
  mode '0600'
  action :create
end

# Create a fetcher object for gathering secrets
fetcher = envkey_secret_fetcher({ 'envkey' => envkey_token }, run_context)

# Write application secrets using the fetcher object.
file '/opt/chef-envkey/application.secret_fetcher' do
  extend EnvkeyCookbook::ClientHelpers
  content fetcher.fetch('VARIABLE_A')
  mode '0600'
  action :create
end
