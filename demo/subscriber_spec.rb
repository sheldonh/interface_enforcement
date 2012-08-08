# The production code
#####################

class Subscriber

  def initialize(publisher)
    @publisher = publisher
  end

  def gets
    @publisher.gets
  end

end

class Publisher

  def initialize(message)
    @message = message
  end

  def gets
    @message.chomp << "\n"
  end

end

# The test suite
################

require 'spec_helper'
require 'test_interface'

module PublisherInterface

  CONTRACT = {
    :gets => {
      :args => ->(a) { a.empty? },
      :return => ->(o) { o.respond_to?(:to_s) and o.to_s.end_with?("\n") },
    }
  }

  def self.wrap(subject)
    TestInterface::Interface.new(CONTRACT).proxy(subject)
  end

end

describe Publisher do

  it "this example forces us to change the PublisherInterface when the Publisher changes" do
    publisher = PublisherInterface.wrap(Publisher.new("the message"))
    publisher.gets.should eq("the message\n")
  end

end

describe Subscriber do

  it "this example passes by mistake, because the test double does not behave like a Publisher" do
    publisher = double(Publisher, :gets => "a message", :test => true)
    subscriber = Subscriber.new(publisher)
    subscriber.gets.should eq("a message")
  end

  it "this example fails correctly, because Publisher#gets returns a line-terminated string" do
    publisher = PublisherInterface.wrap(double(Publisher, :gets => "a message", :test => true))
    subscriber = Subscriber.new(publisher)
    subscriber.gets.should eq("a message")
  end

end

