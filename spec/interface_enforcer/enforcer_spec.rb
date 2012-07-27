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

    describe "type" do

      it "is allowed if of a contracted type" do
        subject = TestInterface::Enforcer.new(ask: { returns: String }).wrap(real_subject)
        subject.ask.should eq("the default")
      end

      it "raises TestInterface::ReturnViolation if of uncontracted type" do
        subject = TestInterface::Enforcer.new(ask: { returns: Numeric }).wrap(real_subject)
        expect { subject.ask }.to raise_error(TestInterface::ReturnViolation)
      end

    end

    describe "rule" do

      it "allows the return value if it returns true for the return value" do
        subject = TestInterface::Enforcer.new(ask: { returns: ->(o) { o.include?('default') } }).wrap(real_subject)
        subject.ask.should eq("the default")
      end

      it "raises TestInterface::ReturnViolation if it returns false for the return value" do
        subject = TestInterface::Enforcer.new(ask: { returns: ->(o) { o.include?('impossible') } }).wrap(real_subject)
        expect { subject.ask }.to raise_error(TestInterface::ReturnViolation)
      end

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

    describe "type" do

      it "is allowed if contracted for one argument" do
        subject = TestInterface::Enforcer.new(:tell => { args: String }).wrap(real_subject)
        expect { subject.tell("new knowledge") }.to_not raise_error
      end

      it "raises a TestInterface::ArgumentTypeViolation if uncontracted for one argument" do
        subject = TestInterface::Enforcer.new(:tell => { args: Numeric }).wrap(real_subject)
        expect { subject.tell("new knowledge") }.to raise_error TestInterface::ArgumentTypeViolation
      end

    end

    describe "types" do

      it "are allowed if each one is contracted" do
        subject = TestInterface::Enforcer.new(:ignore => { args: [ String, :any ] }).wrap(real_subject)
        expect { subject.ignore("wrong", "types") }.to_not raise_error
      end

      it "raise TestInterface::ArgumentTypeViolation if not all contracted" do
        subject = TestInterface::Enforcer.new(:ignore => { args: [ :any, Numeric ] }).wrap(real_subject)
        expect { subject.ignore("wrong", "types") }.to raise_error TestInterface::ArgumentTypeViolation
      end

    end

    describe "count" do

      it "raises TestInterface::ArgumentCountViolation if too numerous" do
        subject = TestInterface::Enforcer.new(:ignore => { args: Object }).wrap(real_subject)
        expect { subject.ignore("too", "many arguments") }.to raise_error TestInterface::ArgumentCountViolation
      end

      it "raises TestInterface::ArgumentCountViolation if too few" do
        subject = TestInterface::Enforcer.new(:tell => { args: [ String, String ] }).wrap(real_subject)
        expect { subject.tell("new knowledge") }.to raise_error TestInterface::ArgumentCountViolation
      end

    end

    describe "rule" do

      let(:rule)     { ->(a) { a.size == 1 and a.first == "new knowledge" } }
      let(:enforcer) { TestInterface::Enforcer.new(tell: { args: rule }, :ask => :allowed) }
      let(:subject)  { enforcer.wrap(real_subject) }

      it "allows the arguments if it returns true for them" do
        subject.tell("new knowledge")
        subject.ask.should == "new knowledge"
      end

      it "raises TestInterface::ArgumentRuleViolation it it returns false for them" do
        expect { subject.tell("old knowledge") }.to raise_error TestInterface::ArgumentRuleViolation
      end

    end

  end

end
