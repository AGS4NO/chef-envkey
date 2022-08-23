unified_mode true

provides :envkey_package

property :global, [true, false], default: true
property :package, String, name_property: true
property :version, String, default: 'latest'

action :install do
  %w(bin src).each do |source_directory|
    directory "#{source_package_path}/#{source_directory}" do
      group 'root'
      mode '0751'
      owner 'root'
      action :create
      recursive true
    end
  end

  if new_resource.package == 'envkey-source' || new_resource.package == 'source'
    remote_file "#{Chef::Config['file_cache_path']}/#{source_package_archive}" do
      group 'root'
      mode '0750'
      owner 'root'
      source source_package_archive_url
      action :create
      not_if { ::File.exist?("#{source_package_path}/src/#{source_package_version}/envkey-source") }
    end

    archive_file "#{source_package_archive}" do
      destination "#{source_package_path}/src/#{source_package_version}"
      path "#{Chef::Config['file_cache_path']}/#{source_package_archive}"
      action :extract
      not_if { ::File.exist?("#{source_package_path}/src/#{source_package_version}") }
      overwrite true
    end

    file "#{Chef::Config['file_cache_path']}/#{source_package_archive}" do
      action :delete
    end

    link "#{source_package_path}/bin/envkey-source" do
      to "#{source_package_path}/src/#{source_package_version}/envkey-source"
      action :create
    end

    link '/usr/local/bin/envkey-source' do
      to "#{source_package_path}/src/#{source_package_version}/envkey-source"
      action :create
      only_if { new_resource.global }
    end
  else
    Chef::Log.fatal("Envkey package #{package} is not supported.")
  end
end

action_class do
  include EnvkeyCookbook::PackageHelpers

  def source_package_archive
    "envkey-source_#{source_package_version}_linux_amd64.tar.gz"
  end

  def source_package_archive_url
    "https://envkey-releases.s3.amazonaws.com/envkeysource/release_artifacts/#{source_package_version}/#{source_package_archive}"
  end

  def source_package_version
    if new_resource.version == 'latest'
      version_request = Chef::HTTP.new('https://envkey-releases.s3.amazonaws.com/latest/envkeysource-version.txt')
      version_request.request('get', version_request.url)
    else
      new_resource.version
    end
  end
end
