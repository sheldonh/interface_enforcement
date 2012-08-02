require 'spec_helper'

describe TestInterface::Enforcer do

  include TestInterface::RspecSugar

  let(:real_subject) do
    class Subject
      def ask
        @knowledge || "the default"
      end

      def tell(something)
        @knowledge = something
      end

      def ignore(*args)
        ignore = args
      end

      private

      def private_method
        "a secret"
      end
    end
    Subject.new
  end

  describe "method invocation" do

    it "is delegated to the subject if contracted" do
      subject = enforce(:ask => :allowed, :tell => :allowed).on(real_subject)
      subject.tell("new knowledge")
      subject.ask.should eq("new knowledge")
    end

    it "raises a TestInterface::MethodViolation if uncontracted" do
      subject = enforce(tell: :allowed).on(real_subject)
      expect { subject.ask }.to raise_error(TestInterface::MethodViolation)
    end

    it "does not expose private methods" do
      subject = enforce(private_method: :allowed).on(real_subject)
      expect { subject.private_method }.to raise_error TestInterface::ExceptionViolation
      expect { subject.send(:private_method) }.to raise_error TestInterface::ExceptionViolation
    end

  end

  describe "return values" do

    it "are allowed if uncontracted" do
      subject = enforce(ask: { :args => :any }).on(real_subject)
      subject.ask.should eq("the default")
    end

    it "are allowed if unconstrained" do
      subject = enforce(ask: { :returns => :any }).on(real_subject)
      subject = enforce(ask: { :returns => :any }).on(real_subject)
      subject.ask.should eq("the default")
    end

    describe "type" do

      it "is allowed if of a contracted type" do
        subject = enforce(ask: { returns: String }).on(real_subject)
        subject.ask.should eq("the default")
      end

      it "raises TestInterface::ReturnViolation if of uncontracted type" do
        subject = enforce(ask: { returns: Numeric }).on(real_subject)
        expect { subject.ask }.to raise_error(TestInterface::ReturnViolation)
      end

    end

    describe "rule" do

      it "allows the return value if it returns true for the return value" do
        subject = enforce(ask: { returns: ->(o) { o.include?('default') } }).on(real_subject)
        subject.ask.should eq("the default")
      end

      it "raises TestInterface::ReturnViolation if it returns false for the return value" do
        subject = enforce(ask: { returns: ->(o) { o.include?('impossible') } }).on(real_subject)
        expect { subject.ask }.to raise_error(TestInterface::ReturnViolation)
      end

    end

  end

  describe "arguments" do

    it "are allowed if uncontracted" do
      subject = enforce(tell: { :returns => Object }).on(real_subject)
      expect { subject.tell("new knowledge") }.to_not raise_error
    end

    it "are allowed if unconstrained" do
      subject = enforce(tell: { :args => :any }).on(real_subject)
       subject.tell("new knowledge")
      expect { subject.tell("new knowledge") }.to_not raise_error
    end

    describe "type" do

      it "is allowed if contracted for one argument" do
        subject = enforce(:tell => { args: String }).on(real_subject)
        expect { subject.tell("new knowledge") }.to_not raise_error
      end

      it "raises a TestInterface::ArgumentTypeViolation if uncontracted for one argument" do
        subject = enforce(:tell => { args: Numeric }).on(real_subject)
        expect { subject.tell("new knowledge") }.to raise_error TestInterface::ArgumentTypeViolation
      end

    end

    describe "types" do

      it "are allowed if each one is contracted" do
        subject = enforce(:ignore => { args: [ String, :any ] }).on(real_subject)
        expect { subject.ignore("wrong", "types") }.to_not raise_error
      end

      it "raise TestInterface::ArgumentTypeViolation if not all contracted" do
        subject = enforce(:ignore => { args: [ :any, Numeric ] }).on(real_subject)
        expect { subject.ignore("wrong", "types") }.to raise_error TestInterface::ArgumentTypeViolation
      end

    end

    describe "count" do

      it "raises TestInterface::ArgumentCountViolation if too numerous" do
        subject = enforce(ignore: { args: Object }).on(real_subject)
        expect { subject.ignore("too", "many arguments") }.to raise_error TestInterface::ArgumentCountViolation
      end

      it "raises TestInterface::ArgumentCountViolation if too few" do
        subject = enforce(tell: { args: [ String, String ] }).on(real_subject)
        expect { subject.tell("new knowledge") }.to raise_error TestInterface::ArgumentCountViolation
      end

      it "raises TestInterface::ArgumentCountViolation if prohibited" do
        subject = enforce(tell: { :args => :none }).on(real_subject)
        expect { subject.tell("new knowledge") }.to raise_error TestInterface::ArgumentCountViolation
      end

    end

    describe "rule" do

      let(:rule)     { ->(a) { a.size == 1 and a.first == "new knowledge" } }
      let(:subject)  { enforce(tell: { args: rule }, :ask => :allowed).on(real_subject) }

      it "allows the arguments if it returns true for them" do
        subject.tell("new knowledge")
        subject.ask.should == "new knowledge"
      end

      it "raises TestInterface::ArgumentRuleViolation it it returns false for them" do
        expect { subject.tell("old knowledge") }.to raise_error TestInterface::ArgumentRuleViolation
      end

    end

  end

  describe "exceptions" do

    class TestExampleError < Exception; end

    it "are allowed if contracted" do
      real_subject.stub(:ask).and_raise TestExampleError
      subject = enforce(:ask => { exceptions: :any }).on(real_subject)
      expect { subject.ask }.to raise_error TestExampleError
    end

    it "are allowed if of contracted type" do
      real_subject.stub(:ask).and_raise TestExampleError
      subject = enforce(:ask => { exceptions: TestExampleError }).on(real_subject)
      expect { subject.ask }.to raise_error TestExampleError
    end

    it "raise TestInterface::ExceptionViolation if not of contracted type" do
      real_subject.stub(:ask).and_raise TestExampleError
      subject = enforce(:ask => { exceptions: ArgumentError }).on(real_subject)
      expect { subject.ask }.to raise_error TestInterface::ExceptionViolation
    end

    it "raise TestInterface::ExceptionViolation if uncontracted" do
      real_subject.stub(:tell).and_raise TestExampleError
      subject = enforce(:tell => { args: :any }).on(real_subject)
      expect { subject.tell("something") }.to raise_error TestInterface::ExceptionViolation
    end

  end

end
