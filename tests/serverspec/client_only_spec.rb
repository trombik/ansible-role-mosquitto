require "spec_helper"
require "serverspec"

package = "mosquitto"
service = "mosquitto"
config  = "/etc/mosquitto/mosquitto.conf"
user    = "mosquitto"
group   = "mosquitto"
ports   = [ 1883 ]
db_dir  = "/var/lib/mosquitto"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  user = "nobody"
  group = "nobody"
  config = "/usr/local/etc/mosquitto/mosquitto.conf"
  db_dir = "/var/db/mosquitto"
  default_group = "wheel"
when "ubuntu"
  group = "nogroup"
when "openbsd"
  user = "_mosquitto"
  group = "_mosquitto"
  db_dir = "/var/db/mosquitto"
end

describe service(service) do
  it do
    # Cannot 'status' mosquitto. Set mosquitto_enable to YES in /etc/rc.conf or use 'onestatus' instead of 'status'.
    pending "serverspec failes when the service is not enabled" if os[:family] == "freebsd"
    should_not be_running
  end
  it { should_not be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should_not be_listening }
  end
end

case os[:family]
when "ubuntu"
  describe package("mosquitto-clients") do
    it { should be_installed }
  end

  describe package("mosquitto") do
    it { should_not be_installed }
  end
else
  describe package("mosquitto") do
    it { should be_installed }
  end
end

%w[ mosquitto_sub mosquitto_pub ].each do |c|
  describe command("#{ c } --help") do
    its(:exit_status) { should eq 1 }
    its(:stderr) { should match(/^$/) }
    its(:stdout) { should match(/^Usage: mosquitto_/) }
  end
end
