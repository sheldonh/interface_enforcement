require 'spec_helper'

describe TestInterface::Enforcer do

  let(:real_subject) {
    class Subject
      def ask; @knowledge || "the default"; end
      def tell(something); @knowledge = something; end
      private; def private_method; "a secret"; end
    end
    Subject.new
  }

  describe "method invocation" do

    it "is delegated to the subject if contracted" do
      subject = TestInterface::Enforcer.new(:ask => :allowed, :tell => :allowed).wrap(real_subject)
      subject.tell("new knowledge")
      subject.ask.should eq("new knowledge")
    end

    it "raises a TestInterface::MethodViolation if uncontracted" do
      subject = TestInterface::Enforcer.new(tell: :allowed).wrap(real_subject)
      expect { subject.ask }.to raise_error(TestInterface::MethodViolation)
    end

    it "honours subject privacy" do
      subject = TestInterface::Enforcer.new(private_method: :allowed).wrap(real_subject)
      expect { subject.private_method }.to raise_error(NoMethodError)
    end

  end

  describe "return values from the subject" do

    it "are allowed if of a contracted type" do
      subject = TestInterface::Enforcer.new(ask: { returns: String }).wrap(real_subject)
      subject.ask.should eq("the default")
    end

    it "raise a TestInterface::ReturnViolation if of uncontracted type" do
      subject = TestInterface::Enforcer.new(ask: { returns: Numeric }).wrap(real_subject)
      expect { subject.ask }.to raise_error(TestInterface::ReturnViolation)
    end

    it "are allowed if the contracted rule is true for them" do
      subject = TestInterface::Enforcer.new(ask: { returns: ->(o) { o.include?('default') } }).wrap(real_subject)
      subject.ask.should eq("the default")
    end

    it "raise a TestInterface::ReturnViolation if the contracted rule is false for them" do
      subject = TestInterface::Enforcer.new(ask: { returns: ->(o) { o.include?('impossible') } }).wrap(real_subject)
      expect { subject.ask }.to raise_error(TestInterface::ReturnViolation)
    end

  end

end
