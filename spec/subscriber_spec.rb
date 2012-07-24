require 'spec_helper'

# This would be provided by the library; you don't define or modify this in
# your own code.
#
class InterfaceEnforcer

  class Violation < RuntimeError; end
  class ArgumentViolation < Violation; end
  class ReturnViolation < Violation; end
  class MethodViolation < Violation; end

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
    get_return_value_from_subject
    enforce_contract_return
    @return_value
  end

  def enforce_contract_args
    method_contract[:args].call(@args) or raise ArgumentViolation
  end

  def get_return_value_from_subject
    @return_value = @subject.send(@method, *@args)
  end

  def enforce_contract_return
    method_contract[:return].call(@return_value) or raise ReturnViolation
  end

  def method_contract
    @contract[@method] or raise MethodViolation
  end

end

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
    @message.chomp << "\n"
  end

end

module PublisherInterface

  CONTRACT = {
    :gets => {
      :args => ->(a) { a.empty? },
      :return => ->(o) { o.is_a?(String) and o.end_with?("\n") },
    }
  }

  def self.attach(subject)
    InterfaceEnforcer.new(CONTRACT).attach(subject)
  end

end

describe Publisher do

  it "prints messages" do
    publisher = PublisherInterface.attach(Publisher.new("the message"))
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
    publisher = PublisherInterface.attach(double(Publisher, :gets => "a message", :test => true))
    subscriber = Subscriber.new(publisher)
    subscriber.gets.should eq("a message")
  end

end

