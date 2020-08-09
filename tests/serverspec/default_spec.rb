require "spec_helper"
require "serverspec"

package = "mosquitto"
service = "mosquitto"
conf_dir = "/etc/mosquitto"
user    = "mosquitto"
group   = "mosquitto"
ports   = [1883, 8883]
db_dir  = "/var/lib/mosquitto"
pid_file = "/var/run/mosquitto.pid"
default_user = "root"
default_group = "root"
extra_group = "cert"

case os[:family]
when "freebsd"
  user = "nobody"
  group = "nobody"
  conf_dir = "/usr/local/etc/mosquitto"
  db_dir = "/var/db/mosquitto"
  default_group = "wheel"
  ca_file = "/etc/ssl/cert.pem"
when "ubuntu"
  group = "mosquitto"
when "openbsd"
  user = "_mosquitto"
  group = "_mosquitto"
  db_dir = "/var/db/mosquitto"
  ca_file = "/etc/ssl/cert.pem"
end
config  = "#{conf_dir}/mosquitto.conf"
keyfile = "#{conf_dir}/certs/private/mosquitto.key"
certfile = "#{conf_dir}/certs/public/mosquitto.pub"
acl_file = "#{conf_dir}/my.acl"
passwd_file = "#{conf_dir}/passwd"
ca_file = "#{conf_dir}/certs/ca.pem"

describe package(package) do
  it { should be_installed }
end

describe group extra_group do
  it { should exist }
end

describe user user do
  it { should belong_to_group extra_group }
end

case os[:family]
when "ubuntu"
  describe package("mosquitto-clients") do
    it { should be_installed }
  end
end

describe file certfile do
  it { should exist }
  it { should be_file }
  it { should be_mode 444 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/^-----BEGIN CERTIFICATE-----$/) }
end

describe file keyfile do
  it { should exist }
  it { should be_file }
  it { should be_mode 440 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/^-----BEGIN RSA PRIVATE KEY-----$/) }
end

describe file(acl_file) do
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by default_user }
  it { should be_grouped_into group }
  its(:content) { should match(/Managed by ansible/) }
  its(:content) { should match(%r{^topic read \$SYS/#}) }
end

describe file passwd_file do
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by default_user }
  it { should be_grouped_into group }
  its(:content) { should match(/Managed by ansible/) }
  its(:content) { should match(/^foo:\$\d+\$.*==$/) }
end

describe file(config) do
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by default_user }
  it { should be_grouped_into group }
  its(:content) { should match(/^user #{user}$/) }
  its(:content) { should match(/^pid_file #{pid_file}$/) }
  its(:content) { should match(/^log_dest syslog$/) }
  its(:content) { should match(/^autosave_interval 1800$/) }
  its(:content) { should match(/^persistence true$/) }
  its(:content) { should match(%r{^persistence_location #{Regexp.escape(db_dir)}\/$}) }
  its(:content) { should match(/^persistence_file mosquitto\.db$/) }
  its(:content) { should match(/^keyfile #{keyfile}$/) }
  its(:content) { should match(/^certfile #{certfile}$/) }
  its(:content) { should match(/^listener 1883 #{ Regexp.escape("10.0.2.15") }$/) }
  its(:content) { should match(/^listener 8883 #{ Regexp.escape("10.0.2.15") }$/) }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/mosquitto") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^mosquitto_flags=""$/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe command "echo | openssl s_client -connect 10.0.2.15:8883 -tls1_2" do
  case os[:family]
  when "openbsd", "redhat"
    its(:stdout) { should match(Regexp.escape("subject=/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd/CN=mqtt")) }
  else
    its(:stdout) { should match(/subject=C = AU, ST = Some-State, O = Internet Widgits Pty Ltd, CN = mqtt/) }
  end
end

describe command "echo | openssl s_client -connect 10.0.2.15:1883 -tls1_2" do
  case os[:family]
  when "ubuntu", "redhat"
    its(:stderr) { should match(/write:errno=104/) }
  when "openbsd"
    its(:stderr) { should match(/read:errno=0/) }
  else
    its(:stderr) { should match(/write:errno=0/) }
  end
  its(:stdout) { should match(/#{Regexp.escape("New, (NONE), Cipher is (NONE)")}/) }
end

describe file "#{conf_dir}/passwd" do
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by default_user }
  it { should be_grouped_into group }
  %w[foo bar admin].each do |u|
    its(:content) { should match(/^#{Regexp.escape(u)}:\$\d+\$.*/) }
  end
end
# XXX as mosquitto does not return errors to MQTT clients when ACLs deny the
# access, you cannot test failed attempt to read. in that case, mosquitto_sub
# dos not return.
#
# authenticated users can read `$SYS/#`
%w[foo bar admin].each do |u|
  describe command "mosquitto_sub -h 10.0.2.15 -p 8883 -u #{Shellwords.escape(u)} -P password -t #{Shellwords.escape('$SYS/broker/clients/connected')} -C 1 --cafile #{Shellwords.escape(ca_file)} --insecure -d" do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/^\d+$/) }
  end
end
