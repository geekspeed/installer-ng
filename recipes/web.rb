#TODO: Change pid dir to Scalr's? : )

template "#{node['apache']['dir']}/envvars" do
  source "apache2-envvars.erb"
end

include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_php5'

# Override the default Apache 2 configuration template
# as it includes the LockFile directive which isn't supported
# on our Apache version
# TODO: Check RHEL6 / CentOS.
if node[:platform_family] == 'debian'
  begin
    t = resources("template[apache2.conf]")
    t.source "apache2.conf.erb"
    t.cookbook "scalr-core"
  rescue Chef::Exceptions::ResourceNotFound
    Chef::Log.warn "could not find template apache2.conf to modify"
  end
end

node['apache']['extra_modules'].each do |mod|
  apache_module mod
end

web_app 'scalr' do
  template 'scalr-vhost.conf.erb'
end

%w{000-default.conf default.conf 000-default-ssl.conf default-ssl.conf}.each do |site|
  apache_site site do
    enable false
  end
end
