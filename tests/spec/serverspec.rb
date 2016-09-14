require 'serverspec'

describe docker_image('louisbilliet/bind:testing') do
  its(['ContainerConfig.ExposedPorts']) { should include '53/tcp' }
  its(['ContainerConfig.ExposedPorts']) { should include '53/udp' }
  its(['Config.Cmd']) { should include '/usr/sbin/named' }
  its(['Config.Cmd']) { should include '-f' }
end

describe docker_container('dns') do
  its(['State.Status']) { should eq "running" }
end

{
  "dns1" => "127.0.0.5",
  "dns2" => "127.0.0.6",
  "www" => "127.0.1.5"
}.each do |name, ip|
  describe command("dig @127.0.0.1 -p 1053 #{name}") do
    its(:stdout) { should match /#{name}.home.\s*604800\s*IN\s*A\s*#{ip}/ }
    its(:stdout) { should match /home.\s*604800\s*IN\s*NS\s*dns1.home./ }
    its(:stdout) { should match /home.\s*604800\s*IN\s*NS\s*dns2.home./ }
  end
end

set :os, family: :debian
set :backend, :docker
set :docker_image, @image.id

describe file('/etc/bind/named.conf') do
  [
    'include "/etc/bind/named.conf.options";',
    'include "/etc/bind/named.conf.local";',
    'include "/etc/bind/named.conf.default-zones";',
  ].each do |line|
    its(:content) { should match /^\s*#{Regexp.escape(line)}/ }
  end
end
describe file('/etc/bind/named.conf.local') do
  [
    'include "/etc/bind/zones.rfc1918";',
    'include "/data/zone.conf";',
  ].each do |line|
    its(:content) { should match /^\s*#{Regexp.escape(line)}/ }
  end
end
describe file('/etc/bind/named.conf.options') do
  [
	'directory "/var/cache/bind";',
	'listen-on { any; };',
	'listen-on-v6 { any; };',
    'dnssec-enable yes;',
	'dnssec-validation auto;',
	'dnssec-lookaside auto;',
  ].each do |line|
    its(:content) { should match /^\s*#{Regexp.escape(line)}/ }
  end
end
