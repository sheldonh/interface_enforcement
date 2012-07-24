require 'spec_helper'
require 'ostruct'

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

class OriginalPublisherInterfaceProxy

  def initialize(publisher)
    @publisher = publisher
  end

  def gets(*args)
    raise InterfaceViolation unless args.empty?
    @publisher.gets(*args).tap { |returns| raise InterfaceViolation unless returns.is_a?(String) or returns.nil? }
  end

end

module PublisherInterfaceProxy

  CONTRACT = { :gets => { :input => :no_args, :output => :string } }

  def self.attach(subject)
    InterfaceProxy.new(CONTRACT).attach(subject)
  end

end

class InterfaceProxy

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
    case @contract[@method][:input]
    when :no_args
      raise InterfaceViolation unless @args.empty?
    end
  end

  def enforce_contract_return
    case @contract[@method][:output]
    when :string
      raise InterfaceViolation unless @return_value.is_a?(String)
    when :numeric
      raise InterfaceViolation unless @return_value.is_a?(Numeric)
    end
  end

end

class InterfaceProxyFactory

  def initialize
    @spec = { :gets => { :input => :no_args, :output => :string } }
  end

  def proxy
    @spec.each do |method, contract|

    end
  end

end

class InterfaceViolation < RuntimeError; end

describe Subscriber do

  it "reads messages from its publisher" do
    publisher = PublisherInterfaceProxy.attach(OpenStruct.new(:gets => "a message"))
    subscriber = Subscriber.new(publisher)
    subscriber.gets.should == "a message"
  end

end

describe Publisher do

  it "prints messages" do
    publisher = PublisherInterfaceProxy.attach(Publisher.new("the message"))
    publisher.gets.should eq("the message")
  end

end

