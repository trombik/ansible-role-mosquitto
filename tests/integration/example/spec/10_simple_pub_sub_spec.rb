require "digest"

context "after the network is working" do

  topic = "nodes/publisher/topic"
  message = Digest::MD5.hexdigest(Time.new.to_i.to_s)

  describe server(:publisher) do

    it "publishes a value, #{ message }, in topic, #{ topic } within 1 minute" do
      result = current_server.ssh_exec("timeout 1m mosquitto_pub --host #{ server(:server).server.address } --topic #{ topic } -m #{ message } --qos 1 --retain --debug")
      expect(result).to match(/received CONNACK$/)
      expect(result).to match(/received PUBACK/)
      expect(result).not_to match(/^Error:/)
    end

  end

  describe server(:subscriber) do

    it "receives the value, #{ message }, in #{ topic } within 1 minute" do
      result = current_server.ssh_exec("timeout 1m mosquitto_sub --host #{ server(:server).server.address } --topic #{ topic } -C 1 --debug")
      expect(result).to match(/received CONNACK$/)
      expect(result).to match(/received SUBACK$/)
      expect(result).to match(/received PUBLISH/)
      expect(result).to match(/^#{ message }$/)
    end
  end

end
