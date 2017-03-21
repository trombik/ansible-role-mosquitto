require "spec_helper"

class ServiceNotReady < StandardError
end

sleep 10 if ENV["JENKINS_HOME"]

context "after provisioning finished" do

  describe server(:subscriber) do

    it "should be able to ping server" do
      result = current_server.ssh_exec("ping -c 1 #{ server(:server).server.address } && echo OK")
      expect(result).to match(/OK/)
    end

  end

  describe server(:publisher) do

    it "should be able to ping server" do
      result = current_server.ssh_exec("ping -c 1 #{ server(:server).server.address } && echo OK")
      expect(result).to match(/OK/)
    end

  end

  describe server(:server) do

    [ :subscriber, :publisher ].each do |i|
      it "should be able to ping #{ i }" do
        result = current_server.ssh_exec("ping -c 1 #{ server(i).server.address } && echo OK")
        expect(result).to match(/OK/)
      end
    end

  end

end
