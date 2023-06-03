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

class Chef
  class EnvkeySecretFetcher
    SECRET_FETCHERS = %i(envkey).freeze

    # Returns a configured and validated instance of a 
    # [Chef::SecretFetcher::Base] for the Envkey service and configuration.
    #
    # @param service [Symbol] the identifier for the service that will support this request. 
    # Must be in SECRET_FETCHERS
    # @param config [Hash] configuration that the secrets service requires
    # @param run_context [Chef::RunContext] the run context this is being invoked from
    def self.for_service(service, config, run_context)
      fetcher = case service
                when :envkey
                  require_relative 'envkey'
                  Chef::SecretFetcher::Envkey.new(config, run_context)
                when nil, ''
                  raise Chef::Exceptions::Secret::MissingFetcher.new('Missing secret service', SECRET_FETCHERS)
                else
                  raise Chef::Exceptions::Secret::InvalidFetcherService.new("Unsupported secret service: '#{service}'", SECRET_FETCHERS)
                end
      fetcher.validate!
      fetcher
    end
  end
end
