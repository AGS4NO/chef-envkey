#
# Chef Infra Documentation
# https://docs.chef.io/libraries/
#
# Copyright:: 2023, Stephen Nelson <AGS4NO@pm.me>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module EnvkeyCookbook
  module ClientHelpers
    def envkey_secret(name: nil, _version: nil, service: nil, config: {})
      Chef::Log.warn("The `envkey_secret` helper for #{service} extends the secrets Chef Infra language helper.")
      Chef::Log.warn <<~EOM.gsub('\n', ' ')
          The secrets Chef Infra language helper is currently in beta. If you have feedback or you would
          like to be part of the future design of this helper e-mail us at secrets_management_beta@progress.com"
        EOM
      sensitive(true) if is_a?(Chef::Resource)
      Chef::SecretFetcher::Envkey.new(config, run_context).fetch(name)
    end

    def envkey_secret_fetcher(config, run_context)
      Chef::Log.warn('The `envkey_secret_fetcher` helper extends the secrets Chef Infra language helper.')
      Chef::Log.warn <<~EOM.gsub('\n', ' ')
          The secrets Chef Infra language helper is currently in beta. If you have feedback or you would
          like to be part of the future design of this helper e-mail us at secrets_management_beta@progress.com"
        EOM
      sensitive(true) if is_a?(Chef::Resource)
      fetcher = Chef::SecretFetcher::Envkey.new(config, run_context)
      fetcher.validate!
      fetcher
    end

    def envkey_source_vars(envkey)
      require 'json'
      vars = envkey_source(envkey, 'json')
      JSON.parse(vars)
    end

    private

    def envkey_source(envkey, out_format)
      extend EnvkeyCookbook::PackageHelpers

      Chef::Log.fatal('Call to `envkey_source` missing ENVKEY argument.') if envkey.to_s == ''

      ENV['ENVKEY'] = envkey.to_s

      source_request = Mixlib::ShellOut.new(
        "#{source_package_bin} \
        --client-name envkey-chef \
        --client-version '0.1.0' \
        --#{out_format} 2>&1"
      )

      source_request.run_command
      validate_source_response(source_request.stdout)
    end

    def validate_source_response(source_response)
      if source_response && source_response.gsub('\n', '').gsub('\r', '') != '' && !source_response.start_with?('error:')
        source_response
      else
        Chef::Log.fatal("Failed to parse `envkey-source` response - #{source_response}")
      end
    end
  end

  module PackageHelpers
    def source_package_bin
      "#{source_package_path}/bin/envkey-source"
    end

    def source_package_path
      '/opt/envkey'
    end
  end
end

Chef::DSL::Recipe.send(:include, EnvkeyCookbook::ClientHelpers)
