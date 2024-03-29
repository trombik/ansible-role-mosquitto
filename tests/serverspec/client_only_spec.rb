require "spec_helper"
require "serverspec"

service = "mosquitto"
ports = [1883]

describe service(service) do
  it { should_not be_running }
  it { should_not be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should_not be_listening }
  end
end

case os[:family]
when "ubuntu", "devuan"
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

%w[jq rsync].each do |p|
  describe package p do
    it { should be_installed }
  end
end

describe package "git" do
  it { should_not be_installed }
end

%w[mosquitto_sub mosquitto_pub].each do |c|
  describe command("#{c} --help") do
    its(:exit_status) { should eq 1 }
    its(:stderr) { should match(/^$/) }
    its(:stdout) { should match(/^Usage: mosquitto_/) }
  end
end
