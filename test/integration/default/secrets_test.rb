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
    its('content') { should match(/ENVKEY_TEST_VARIABLE='ENVKEY_TEST_SECRET'/) }
  end

  describe json('/opt/chef-envkey/application.json') do
    its('ENVKEY_TEST_VARIABLE') { should eq 'ENVKEY_TEST_SECRET' }
  end

  describe file('/opt/chef-envkey/application.pam') do
    it { should exist }
    its('content') { should match(/ENVKEY_TEST_VARIABLE='ENVKEY_TEST_SECRET'/) }
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
