require 'spec_helper'

describe Backend do
  describe "creation" do
    it "creates an instance with valid options" do
      expect { Backend.new(host: "127.0.0.1", port: 6379) }.not_to raise_error
    end

    it "creates an instance with valid options and password" do
      expect { Backend.new(host: "127.0.0.1", port: 6379, password: "password") }.not_to raise_error
    end

    it "does not create instance without options" do
      expect { Backend.new }.to raise_error
    end

    it "does not create an instance without host" do
      expect { Backend.new(port: 6379) }.to raise_error
    end

    it "does not create an instance without port" do
      expect { Backend.new(host: "127.0.0.1") }.to raise_error
    end
  end

  describe "rugged integration" do
    pending
  end
end
