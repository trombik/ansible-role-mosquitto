require "spec_helper"
require "serverspec"

package = "mosquitto"
service = "mosquitto"
config  = "/etc/mosquitto/mosquitto.conf"
user    = "mosquitto"
group   = "mosquitto"
ports   = [1883]
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

case os[:family]
when "ubuntu"
  describe package("mosquitto-clients") do
    it { should be_installed }
  end
end

describe file(config) do
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by default_user }
  it { should be_grouped_into group }
  its(:content) { should match(/^user #{user}$/) }
  its(:content) { should match(/^pid_file #{pid_file}$/) }
  its(:content) { should match(/^bind_address #{ Regexp.escape("10.0.2.15") }$/) }
  its(:content) { should match(/^port #{ ports.first }$/) }
  its(:content) { should match(/^log_dest syslog$/) }
  its(:content) { should match(/^autosave_interval 1800$/) }
  its(:content) { should match(/^persistence true$/) }
  its(:content) { should match(%r{^persistence_location #{Regexp.escape(db_dir)}\/$}) }
  its(:content) { should match(/^persistence_file mosquitto\.db$/) }
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
