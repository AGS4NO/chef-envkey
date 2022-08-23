unified_mode true

provides :envkey_source_file

description <<~DESC
  Use the **envkey_source_file** resource to create environment compaitble variable files.
DESC

examples <<~EXAMPLES
  The following examples demonstrate various approaches for using the **envkey_source_file** resource in recipes:
  **Source environment variables from EnvKey to a file**
  ```ruby
  envkey_source_package 'envkey-source' do
    action :install
    compile_time true
    version '2.0.26'
  end

  envkey_source_file '/opt/app/.env' do
    envkey 'envkey-token'
    format 'dot-env'
    owner 'root'
    group 'root'
    mode '600'
  end
  ```
EXAMPLES

property :envkey, String, required: true, sensitive: true,
  description: 'A required token used to authenticate with EnvKey.'

property :out_format, String, default: 'dot-env',
  description: 'The content format applied to all files created by the resource.'

property :owner, [String, Integer], default: 'root',
  description: 'The owner applied to all files created by the resource.'

property :group, [String, Integer], default: 'root',
  description: 'The group ownership applied to all files created by the resource.'

property :mode, [Integer, String], default: '640',
  description: 'The permission mode applied to all files created by the resource.'

action :create do
  file_content = envkey_source(new_resource.envkey, new_resource.out_format)

  file new_resource.name do
    content file_content
    group new_resource.group
    mode new_resource.mode
    owner new_resource.owner
    action :create
    sensitive true
  end
end

action_class do
  include EnvkeyCookbook::ClientHelpers
end
