require 'spec_helper'

describe Backend do
  it "creates an instance" do
    expect { Backend.new }.not_to raise_error
  end
end
