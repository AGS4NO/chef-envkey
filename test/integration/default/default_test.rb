# Chef InSpec test for recipe envkey_test::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

control 'default' do
  impact 'critical'
  title 'Default'
  desc 'Ensure the envkey-source application is available.'
  tag 'envkey'

  describe command('/usr/local/bin/envkey-source') do
    it { should exist }
  end

  describe command('/usr/local/bin/envkey-source --version') do
    its('stdout') { should match /^([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$/ }
  end
end
