require 'spec_helper'

describe TestInterface::Enforcer do

  let(:real_subject) {
    class Subject
      def ask; @knowledge || "the default"; end
      def tell(something); @knowledge = something; end
      def ignore(this, that); end
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

  describe "return values" do

    it "are allowed if uncontracted" do
      subject = TestInterface::Enforcer.new(ask: { :args => :any }).wrap(real_subject)
      subject.ask.should eq("the default")
    end

    it "are allowed if unconstrained" do
      subject = TestInterface::Enforcer.new(ask: { :returns => :any }).wrap(real_subject)
      subject.ask.should eq("the default")
    end

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

  describe "arguments" do

    it "are allowed if uncontracted" do
      subject = TestInterface::Enforcer.new(tell: { :returns => Object }).wrap(real_subject)
      expect { subject.tell("new knowledge") }.to_not raise_error
    end

    it "are allowed if unconstrained" do
      subject = TestInterface::Enforcer.new(tell: { :args => :any }).wrap(real_subject)
       subject.tell("new knowledge")
      expect { subject.tell("new knowledge") }.to_not raise_error
    end

  end

  describe "argument type" do

    it "is allowed if contracted for one argument" do
      subject = TestInterface::Enforcer.new(:tell => { args: String }).wrap(real_subject)
      expect { subject.tell("new knowledge") }.to_not raise_error
    end

    it "raises a TestInterface::ArgumentTypeViolation if uncontracted for one argument" do
      subject = TestInterface::Enforcer.new(:tell => { args: Numeric }).wrap(real_subject)
      expect { subject.tell("new knowledge") }.to raise_error TestInterface::ArgumentTypeViolation
    end

    it "is allowed if each one is contracted" do
      subject = TestInterface::Enforcer.new(:ignore => { args: [ String, :any ] }).wrap(real_subject)
      expect { subject.ignore("wrong", "types") }.to_not raise_error
    end

    it "raise TestInterface::ArgumentTypeViolation if not all contracted" do
      subject = TestInterface::Enforcer.new(:ignore => { args: [ :any, Numeric ] }).wrap(real_subject)
      expect { subject.ignore("wrong", "types") }.to raise_error TestInterface::ArgumentTypeViolation
    end

  end

  describe "argument count" do

    it "raise TestInterface::ArgumentCountViolation if too numerous" do
      subject = TestInterface::Enforcer.new(:ignore => { args: Object }).wrap(real_subject)
      expect { subject.ignore("too", "many arguments") }.to raise_error TestInterface::ArgumentCountViolation
    end

    it "raise TestInterface::ArgumentCountViolation if too few" do
      subject = TestInterface::Enforcer.new(:tell => { args: [ String, String ] }).wrap(real_subject)
      expect { subject.tell("new knowledge") }.to raise_error TestInterface::ArgumentCountViolation
    end

  end

end
