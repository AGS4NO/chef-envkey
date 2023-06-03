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

require 'chef/exceptions'
require 'chef/secret_fetcher/base'
require 'json'

begin
  require 'envkey'
rescue => e
  Chef::Log.fatal('Filed to initialize envkey gem') unless e.message =~ /ENVKEY missing/
end

class Chef
  # == Chef::SecretFetcher::Envkey
  # A fetcher that fetches a secret from Envkey. Supports fetching with version.
  #
  # This initial iteration authenticates via the ENVKEY token.
  #
  # @example
  #
  # fetcher = EnvkeySecretFetcher.for_service(:envkey, { 'envkey' => envkey_token }, run_context )
  # fetcher.fetch('VARIABLE')
  #
  FETCH_ENV_PATH = Envkey::Platform.fetch_env_path.freeze
  class SecretFetcher
    class Envkey < Base
      def do_fetch(identifier, _version)
        # TODO: Set the client version from cookbook metadata
        # client_version = Chef::Node.run_context.cookbook_collection['envkey'].metadata.version
        fetch_env_request = Mixlib::ShellOut.new(
            "#{FETCH_ENV_PATH} \
            --client-name chef-envkey \
            --client-version '0.1.0' \
            --json 2>&1",
          environment: { 'ENVKEY': config['envkey'] })

        fetch_env_request.run_command
        fetch_env_response = validate_response(fetch_env_request.stdout)

        res = JSON.parse(fetch_env_response)
        raise Chef::Exceptions::Secret::FetchFailed.new("Secret #{identifier}) not found.", nil) unless res.fetch(identifier)
        res.fetch(identifier)
      end

      def validate!
        if config.class != Hash
          raise Chef::Exceptions::Secret::ConfigurationInvalid.new('The Envkey fetcher requires a configuration hash', nil)
        end

        if config['envkey'].nil? || config['envkey'] == ''
          raise Chef::Exceptions::Secret::ConfigurationInvalid.new("The Envkey service config requires an 'ENVKEY' token", nil)
        end
      end

      private

      def validate_response(fetch_env_response)
        if fetch_env_response && fetch_env_response.gsub('\n', '').gsub('\r', '') != '' && !fetch_env_response.start_with?('error:')
          fetch_env_response
        else
          raise Chef::Exceptions::Secret::FetchFailed.new('Failed to validate envkey secrets.', nil)
        end
      end
    end
  end
end
