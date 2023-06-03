# EnvKey Cookbook

[![CI](https://github.com/AGS4NO/chef-envkey/actions/workflows/ci.yml/badge.svg)](https://github.com/AGS4NO/chef-envkey/actions/workflows/ci.yml)

The EnvKey Cookbook provides resources for installing envkey as well as pulling and managing secret configurations on system.

## Scope

This cookbook provides resources to install and interact with [EnvKey](https://www.envkey.com/) configuration and secrets manager.

## Requirements

- Network accessible system for installing the EnvKey source binary

## Tested Platform Support

- Debian 10/11
- Ubuntu 20.04/22.04
- Rocky 8

## Usage

- Add `depends 'envkey'` to your cookbook's metadata.rb
- Use the resources shipped in cookbook in a recipe, the same way you'd use core Chef resources (file, template, directory, package, etc).

```ruby
# Write all application secrets to a .env file using the `envkey_source_file` helper.
envkey_source_file "/opt/chef-envkey/application.env" do
  envkey envkey_token
  out_format 'dot-env'
  owner 'root'
  group 'root'
  mode '600'
  action :create
end

# Write all application secrets to a JSON file using the `envkey_source_file` helper.
envkey_source_file "/opt/chef-envkey/application.json" do
  envkey envkey_token
  out_format 'json'
  owner 'root'
  group 'root'
  mode '600'
  action :create
end

# Write all application secrets to a PAM file using the `envkey_source_file` helper.
envkey_source_file "/opt/chef-envkey/application.pam" do
  envkey envkey_token
  out_format 'pam'
  owner 'root'
  group 'root'
  mode '600'
  action :create
end

```

## Test Cookbooks as Examples

The cookbooks run by test-kitchen make excellent usage examples.

Those recipes are found at [test/cookbooks/envkey_test/](/test/cookbooks/envkey_test/).

## Resources Overview

- [envkey_source_file](#envkey_source_file): resource to create application secret files
- [envkey_source_package](#envkey_source_package): install the envkey source package

## Getting Started

Here's a quick example of installing EnvKey source and creating a .env secrets file

```ruby
# Install EnvKey source from Ruby Gems
include_recipe 'envkey::default'

# Get the ENVKEY token for the applcation named 'chef-envkey' from a vault item.
envkey_token = chef_vault_item('envkey', 'keys')[node.policy_group]['chef-envkey']

# Create an application directory
directory '/opt/chef-envkey'

# Write all application secrets to a .env file using the `envkey_source_file` helper.
envkey_source_file "/opt/chef-envkey/application.#{out_format}" do
  envkey envkey_token
  out_format 'dot-env'
  owner 'root'
  group 'root'
  mode '600'
  action :create
end
```
