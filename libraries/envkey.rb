#
# Chef Infra Documentation
# https://docs.chef.io/libraries/
#
# Copyright:: 2022, Stephen Nelson <AGS4NO@pm.me>
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

require 'chef/secret_fetcher/base'

class Chef
  # == Chef::SecretFetcher::Envkey
  # An implementation of a secrets fetcher using Envkey.
  #
  # Usage Example:
  #
  # fetcher = envkey_secret_fetcher({ 'envkey' => '#{ENVKEY}' }, run_context)
  # fetcher.fetch('VARIABLE_A')
  #
  # envkey_secret(name: 'VARIABLE_A', service: :envkey, config: { 'envkey' => '#{ENVKEY}' })
  class SecretFetcher
    class Envkey < Base
      def validate!
        if config.class != Hash
          raise Chef::Exceptions::Secret::ConfigurationInvalid.new('The Envkey fetcher requires a config hash', nil)
        end

        if config['envkey'].nil? || config['envkey'] == ''
          raise Chef::Exceptions::Secret::ConfigurationInvalid.new("The Envkey service config requires an 'ENVKEY' token", nil)
        end
      end

      def do_fetch(identifier, _version)
        extend EnvkeyCookbook::ClientHelpers

        res = envkey_source_vars(config['envkey'])

        raise Chef::Exceptions::Secret::FetchFailed.new("Secret #{identifier}) not found.", nil) unless res.fetch(identifier)
        res.fetch(identifier)
      end
    end
  end
end
