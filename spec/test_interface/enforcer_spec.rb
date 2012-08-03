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

  private

  def private_method
    "a secret"
  end
end

describe TestInterface::Enforcer do

  include TestInterface::RspecSugar

  describe "method invocation" do

    it "is delegated to the subject if contracted" do
      subject = enforce(:get => :allowed, :set => :allowed).on(Subject.new)
      subject.set("new knowledge")
      subject.get.should eq("new knowledge")
    end

    it "raises a TestInterface::MethodViolation if uncontracted" do
      subject = enforce(:set => :allowed).on(Subject.new)
      expect { subject.get }.to raise_error(TestInterface::MethodViolation)
    end

    it "does not expose private methods" do
      subject = enforce(:private_method => :allowed).on(Subject.new)
      expect { subject.private_method }.to raise_error NoMethodError
      expect { subject.send(:private_method) }.to raise_error NoMethodError
    end

  end

  describe "return values" do

    it "are allowed if uncontracted" do
      subject = enforce(get: { :args => :any }).on(Subject.new)
      subject.get.should eq("the default")
    end

    it "are allowed if unconstrained" do
      subject = enforce(get: { :returns => :any }).on(Subject.new)
      subject.get.should eq("the default")
    end

    describe "type" do

      it "is allowed if of a contracted type" do
        subject = enforce(get: { returns: String }).on(Subject.new)
        subject.get.should eq("the default")
      end

      it "raises TestInterface::ReturnViolation if of uncontracted type" do
        subject = enforce(get: { returns: Numeric }).on(Subject.new)
        expect { subject.get }.to raise_error(TestInterface::ReturnViolation)
      end

    end

    describe "rule" do

      it "allows the return value if it returns true for the return value" do
        subject = enforce(get: { returns: ->(o) { o.include?('default') } }).on(Subject.new)
        subject.get.should eq("the default")
      end

      it "raises TestInterface::ReturnViolation if it returns false for the return value" do
        subject = enforce(get: { returns: ->(o) { o.include?('impossible') } }).on(Subject.new)
        expect { subject.get }.to raise_error(TestInterface::ReturnViolation)
      end

    end

  end

  describe "arguments" do

    it "are allowed if uncontracted" do
      subject = enforce(set: { :returns => Object }).on(Subject.new)
      expect { subject.set("new knowledge") }.to_not raise_error
    end

    it "are allowed if unconstrained" do
      subject = enforce(set: { :args => :any }).on(Subject.new)
      subject.set("new knowledge")
      expect { subject.set("new knowledge") }.to_not raise_error
    end

    describe "type" do

      it "is allowed if contracted for one argument" do
        subject = enforce(set: {args: String}).on(Subject.new)
        expect { subject.set("new knowledge") }.to_not raise_error
      end

      it "raises a TestInterface::ArgumentTypeViolation if uncontracted for one argument" do
        subject = enforce(set: {args: Numeric}).on(Subject.new)
        expect { subject.set("new knowledge") }.to raise_error TestInterface::ArgumentTypeViolation
      end

    end

    describe "types" do

      it "are allowed if each one is contracted" do
        subject = enforce(ignore: {args: [String, :any]}).on(Subject.new)
        expect { subject.ignore("wrong", "types") }.to_not raise_error
      end

      it "raise TestInterface::ArgumentTypeViolation if not all contracted" do
        subject = enforce(ignore: {args: [:any, Numeric]}).on(Subject.new)
        expect { subject.ignore("wrong", "types") }.to raise_error TestInterface::ArgumentTypeViolation
      end

    end

    describe "count" do

      it "raises TestInterface::ArgumentCountViolation if too numerous" do
        subject = enforce(ignore: { args: Object }).on(Subject.new)
        expect { subject.ignore("too", "many arguments") }.to raise_error TestInterface::ArgumentCountViolation
      end

      it "raises TestInterface::ArgumentCountViolation if too few" do
        subject = enforce(ignore: { args: [ String, String ] }).on(Subject.new)
        expect { subject.ignore("too few arguments") }.to raise_error TestInterface::ArgumentCountViolation
      end

      it "raises TestInterface::ArgumentCountViolation if prohibited" do
        subject = enforce(get: { :args => :none }).on(Subject.new)
        expect { subject.get("new knowledge") }.to raise_error TestInterface::ArgumentCountViolation
      end

      it "is allowed to be zero when prohibited" do
        subject = enforce(get: { :args => :none }).on(Subject.new)
        expect { subject.get }.to_not raise_error
      end

    end

    describe "rule" do

      let(:rule)     { ->(a) { a.size == 1 and a.first == "new knowledge" } }
      let(:subject)  { enforce(set: { args: rule }, :get => :allowed).on(Subject.new) }

      it "allows the arguments if it returns true for them" do
        subject.set("new knowledge")
        subject.get.should == "new knowledge"
      end

      it "raises TestInterface::ArgumentRuleViolation it it returns false for them" do
        expect { subject.set("old knowledge") }.to raise_error TestInterface::ArgumentRuleViolation
      end

    end

  end

  describe "exceptions" do

    class TestExampleError < Exception; end

    let(:exploding_subject) do
      Subject.new.tap { |o| o.stub(:get).and_raise TestExampleError }
    end

    it "are allowed if uncontracted" do
      subject = enforce(get: {:args => :any}).on(exploding_subject)
      expect { subject.get }.to raise_error TestExampleError
    end

    it "are allowed if unconstrained" do
      subject = enforce(get: {:exceptions => :any}).on(exploding_subject)
      expect { subject.get }.to raise_error TestExampleError
    end

    it "are allowed if of contracted type" do
      subject = enforce(get: {exceptions: TestExampleError}).on(exploding_subject)
      expect { subject.get }.to raise_error TestExampleError
    end

    it "raise TestInterface::ExceptionViolation if not of contracted type" do
      subject = enforce(get: {exceptions: ArgumentError}).on(exploding_subject)
      expect { subject.get }.to raise_error TestInterface::ExceptionViolation
    end

    it "raises TestInterface::ExceptionViolation if prohibited" do
      subject = enforce(get: {:exceptions => :none}).on(exploding_subject)
      expect { subject.get }.to raise_error TestInterface::ExceptionViolation
    end

    describe "rule" do

      it "allows an exception if it returns true for the exception" do
        rule = ->(e) { true }
        subject = enforce(get: {:exceptions => rule}).on(exploding_subject)
        expect { subject.get }.to raise_error TestExampleError
      end

      it "raises TestInterface::ExceptionViolation it it returns false for the exception" do
        rule = ->(e) { false }
        subject = enforce(get: {:exceptions => rule}).on(exploding_subject)
        expect { subject.get }.to raise_error TestInterface::ExceptionViolation
      end

    end

  end

end
