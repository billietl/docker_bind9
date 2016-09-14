require 'serverspec'
require 'rspec'
require 'rspec-dns'

set :os, family: :debian
set :backend, :docker
set :docker_image, 'louisbilliet/bind:testing'

describe 'DNS custom configuration tests' do
  it "resolves #{name}" do
    expect('home').to have_dns.with_type('SOA').and_rname('root.home').config(nameserver: '127.0.0.1', port: 1053)
    expect('home').to have_dns.with_type('SOA').and_mname('home').config(nameserver: '127.0.0.1', port: 1053)
    expect('home').to have_dns.with_type('NS').at_least(2).config(nameserver: '127.0.0.1', port: 1053)
    expect('dns1.home').to have_dns.with_type('A').and_address('127.0.0.5').config(nameserver: '127.0.0.1', port: 1053)
    expect('dns2.home').to have_dns.with_type('A').and_address('127.0.0.6').config(nameserver: '127.0.0.1', port: 1053)
    expect('www.home').to have_dns.with_type('A').and_address('127.0.1.5').config(nameserver: '127.0.0.1', port: 1053)
  end
end

describe package('bind9') do
  it { should be_installed }
end

describe port('53') do
  it { should be_listening.with('tcp') }
  it { should be_listening.with('udp') }
end

describe process('named') do
  it { should be_running }
end

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
