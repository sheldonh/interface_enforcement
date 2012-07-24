require 'spec_helper'

# This would be provided by the library; you don't define or modify this in
# your own code.
#
class InterfaceEnforcer

  def initialize(contract)
    @contract = contract
    @subject = nil
  end

  def attach(subject)
    @subject = subject
    self
  end

  def method_missing(method, *args)
    @method, @args = method, args
    run_subject_through_contract
  end

  private

  def run_subject_through_contract
    enforce_contract_args
    @return_value = @subject.send(@method, *@args)
    enforce_contract_return
    @return_value
  end

  def enforce_contract_args
    case method_contract[:input]
    when :no_args
      raise InterfaceViolation unless @args.empty?
    end
  end

  def enforce_contract_return
    case method_contract[:output]
    when :string
      raise InterfaceViolation unless @return_value.is_a?(String)
    when :numeric
      raise InterfaceViolation unless @return_value.is_a?(Numeric)
    end
  end

  def method_contract
    @contract[@method] or raise InterfaceViolation
  end

end

class InterfaceViolation < RuntimeError; end

# From here on, it's your own code.
#
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
    @message
  end

end

module PublisherInterface

  CONTRACT = { :gets => { :input => :no_args, :output => :string } }

  def self.attach(subject)
    InterfaceEnforcer.new(CONTRACT).attach(subject)
  end

end

describe Publisher do

  it "prints messages" do
    publisher = PublisherInterface.attach(Publisher.new("the message"))
    publisher.gets.should eq("the message")
  end

end

describe Subscriber do

  it "reads messages from its publisher" do
    publisher = PublisherInterface.attach(double(Publisher, :gets => "a message", :test => true))
    subscriber = Subscriber.new(publisher)
    subscriber.gets.should == "a message"
  end

end

