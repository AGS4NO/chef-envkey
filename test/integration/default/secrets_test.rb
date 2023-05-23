# Chef InSpec test for recipe envkey_test::secrets

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

control 'secrets' do
  impact 'critical'
  title 'Secrets'
  desc 'Ensure the envkey-source application can fetch secrets.'
  tag 'envkey'

  describe file('/opt/chef-envkey/application.credential') do
    its('content') { should match(/SECRET_A/) }
  end

  describe file('/opt/chef-envkey/application.dot-env') do
    it { should exist }
    its('content') { should match(/VARIABLE_A='SECRET_A'\nVARIABLE_B='SECRET_B'\nVARIABLE_BLOCK='SECRET_BLOCK'\n\n/) }
  end

  describe json('/opt/chef-envkey/application.json') do
    its('VARIABLE_A') { should eq 'SECRET_A' }
    its('VARIABLE_B') { should eq 'SECRET_B' }
    its('VARIABLE_BLOCK') { should eq 'SECRET_BLOCK' }
  end

  describe file('/opt/chef-envkey/application.pam') do
    it { should exist }
    its('content') { should match(/export VARIABLE_A='SECRET_A'\nexport VARIABLE_B='SECRET_B'\nexport VARIABLE_BLOCK='SECRET_BLOCK'\n/) }
  end

  describe file('/opt/chef-envkey/application.secret') do
    it { should exist }
    its('content') { should match(/SECRET_A/) }
  end

  describe file('/opt/chef-envkey/application.secret_fetcher') do
    it { should exist }
    its('content') { should match(/SECRET_A/) }
  end
end
