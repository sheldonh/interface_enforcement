require 'spec_helper'

class Subject
  def get
    @knowledge || "the default"
  end

  def set(something)
    @knowledge = something
  end

  def ignore(*args)
    args
  end

  def public_method
    private_method
  end

  protected

  def protected_method
    "a shared secret"
  end

  private

  def private_method
    "a secret"
  end
end

describe TestInterface::Injector do

  describe "method invocation" do

    it "is delegated to the subject if contracted" do
      subject = Subject.new
      TestInterface::Injector.new(TestInterface::Interface.new(:get => :allowed, :set => :allowed)).inject(subject)
      subject.set("new knowledge")
      subject.get.should eq("new knowledge")
    end

    it "raises a NoMethodError if uncontracted" do
      subject = Subject.new
      TestInterface::Injector.new(TestInterface::Interface.new(:set => :allowed)).inject(subject)
      expect { subject.get }.to raise_error TestInterface::MethodViolation
    end

  end

end