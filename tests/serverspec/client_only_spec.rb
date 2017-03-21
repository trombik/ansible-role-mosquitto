require "spec_helper"
require "serverspec"

package = "mosquitto"
service = "mosquitto"
config  = "/etc/mosquitto/mosquitto.conf"
user    = "mosquitto"
group   = "mosquitto"
ports   = [ 1883 ]
db_dir  = "/var/lib/mosquitto"
pid_file = "/var/run/mosquitto.pid"
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

describe package(package) do
  it { should be_installed }
end 

describe service(service) do
  it do
    # Cannot 'status' mosquitto. Set mosquitto_enable to YES in /etc/rc.conf or use 'onestatus' instead of 'status'.
    pending "serverspec failes when the service is not enabled" if os[:family] == "freebsd"
    should_not be_running
  end
  it do
    # sudo -p 'Password: ' /bin/sh -c ls\ /etc/rc3.d/\ \|\ grep\ --\ \'\^S..mosquitto\$\'\ \|\|\ grep\ \'\^\ \*start\ on\'\ /etc/init/mosquitto.conf
    pending "serverspec failes when the service is not enabled" if os[:family] == "ubuntu" && os[:release] == "14.04"
    should_not be_enabled
  end
end

ports.each do |p|
  describe port(p) do
    it { should_not be_listening }
  end
end
