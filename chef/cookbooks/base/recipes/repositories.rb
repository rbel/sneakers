file '/etc/apt/sources.list' do
  content '# Managed by chef'
end

repositories = {
  'openminds_mirror' => 'deb http://mirror.openminds.be/debian squeeze main contrib non-free',
  'squeeze_security' => 'deb http://security.debian.org squeeze/updates main contrib non-free',
  'openminds_apache' => 'deb http://debs.openminds.be squeeze apache2',
  'nginx' => 'deb http://nginx.org/packages/debian squeeze nginx',
  'dotdeb' => "deb http://packages.dotdeb.org squeeze all",
  'mariadb' => 'deb http://mirror2.hs-esslingen.de/mariadb/repo/5.5/debian squeeze main'
}

repository_keys = {
  'openminds_apache' => 'wget -qO - http://debs.openminds.be/debs.openminds.key | apt-key add -',
  'nginx' => 'wget -qO - http://nginx.org/packages/keys/nginx_signing.key | apt-key add -',
  'dotdeb' => 'wget -qO - http://www.dotdeb.org/dotdeb.gpg | apt-key add -',
  'mariadb' => 'apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 1BB943DB'
}

repositories.each do |repository, value|
  file "/etc/apt/sources.list.d/#{repository}.list" do
    owner 'root'
    group 'root'
    mode '0644'
    content value
    notifies :run, "execute[apt-key #{repository}]", :immediately if repository_keys.include? repository
  end
end

file '/etc/apt/sources.list.d/dotdeb-php54.list' do
  owner 'root'
  group 'root'
  mode '0644'
  content 'deb http://packages.dotdeb.org squeeze-php54 all'
  notifies :run, "execute[apt-key dotdeb]", :immediately
  only_if { node[:php][:version] == 'php54' }
end

repository_keys.each do |repository, command|
  execute "apt-key #{repository}" do
    command command
    action :nothing
  end
end

template '/etc/apt/preferences.d/dotdeb_php_pinning' do
  source 'dotdeb_php_pinning.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

execute 'apt-get update -y'
