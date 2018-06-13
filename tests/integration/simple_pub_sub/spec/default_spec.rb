require "spec_helper"

class ServiceNotReady < StandardError
end

sleep 10 if ENV["JENKINS_HOME"]

context "after provisioning finished" do
  describe server(:client1) do
    it "should be able to ping server" do
      result = current_server.ssh_exec("ping -c 1 #{server(:server1).server.address} && echo OK")
      expect(result).to match(/OK/)
    end
  end

  describe server(:server1) do
    it "should be able to ping client" do
      result = current_server.ssh_exec("ping -c 1 #{server(:client1).server.address} && echo OK")
      expect(result).to match(/OK/)
    end
  end

  describe server(:client1) do
    let(:topic) { "foo/bar" }
    let(:value) { "1266193804 42" }
    it "publish a record" do
      puts "mosquitto_pub -h #{server(:server1).server.address} -t #{topic} -m '#{value}' -d -r"
      r = current_server.ssh_exec("mosquitto_pub -h #{server(:server1).server.address} -t #{topic} -m '#{value}' -d -r")
      expect(r).to match(/^Client\s+mosqpub[^ ]+\s+sending CONNECT$/)
      expect(r).to match(/^Client\s+mosqpub[^ ]+\s+received CONNACK$/)
      expect(r).to match(/^Client\s+mosqpub[^ ]+\s+sending PUBLISH.*/)
      expect(r).to match(/^Client\s+mosqpub[^ ]+\s+sending DISCONNECT$/)
    end

    it "receives the record" do
      r = current_server.ssh_exec("mosquitto_sub -h #{server(:server1).server.address} -t #{topic} -C 1 -v")
      expect(r).to match(/^#{topic}\s+#{value}$/)
    end
  end
end
