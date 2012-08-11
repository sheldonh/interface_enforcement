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

describe TestInterface::Proxy do

  include TestInterface::RspecSugar

  describe "method invocation" do

    it "is delegated to the subject if contracted" do
      proxy = interface(:get => :allowed, :set => :allowed).proxy(Subject.new)
      proxy.set("new knowledge")
      proxy.get.should eq("new knowledge")
    end

    it "raises a NoMethodError if uncontracted" do
      proxy = interface(:set => :allowed).proxy(Subject.new)
      expect { proxy.get }.to raise_error(NoMethodError)
    end

    context "private methods" do

      it "raises an ArgumentError if contracted against a private method" do
        expect { interface(:private_method => :allowed).proxy(Subject.new) }.to raise_error ArgumentError
      end

      it "raises an ArgumentError if contracted against a nonexistent method" do
        expect { interface(:nonexistent => :allowed).proxy(Subject.new) }.to raise_error ArgumentError
      end

      it "does not prevent the subject's own access to its own private methods" do
        proxy = interface(:public_method => :allowed).proxy(Subject.new)
        proxy.public_method == "a secret"
      end

    end

    context "protected methods" do

      module SubjectSharing
        def initialize(subject)
          @subject = subject
        end

        def shared_secret
          @subject.protected_method
        end
      end

      class Descendant < Subject
        include SubjectSharing
      end

      class NonDescendant
        include SubjectSharing
      end

      it "does not prevent legitimate access to the subject's protected methods" do
        proxy = interface(:protected_method => :allowed).proxy(Subject.new)
        Descendant.new(proxy).shared_secret.should == "a shared secret"
      end

      it "does not allow illegitimate access to the subject's protected methods" do
        proxy = interface(:protected_method => :allowed).proxy(Subject.new)
        expect { NonDescendant.new(proxy).shared_secret }.to raise_error TestInterface::PrivacyViolation
      end

    end

  end

  describe "return values" do

    it "are allowed if uncontracted" do
      proxy = interface(get: { :args => :any }).proxy(Subject.new)
      proxy.get.should eq("the default")
    end

    it "are allowed if unconstrained" do
      proxy = interface(get: { :returns => :any }).proxy(Subject.new)
      proxy.get.should eq("the default")
    end

    describe "type" do

      it "is allowed if of a contracted type" do
        proxy = interface(get: { returns: String }).proxy(Subject.new)
        proxy.get.should eq("the default")
      end

      it "raises TestInterface::ReturnViolation if of uncontracted type" do
        proxy = interface(get: { returns: Numeric }).proxy(Subject.new)
        expect { proxy.get }.to raise_error(TestInterface::ReturnViolation)
      end

    end

    describe "rule" do

      it "allows the return value if it returns true for the return value" do
        proxy = interface(get: { returns: ->(o) { o.include?('default') } }).proxy(Subject.new)
        proxy.get.should eq("the default")
      end

      it "raises TestInterface::ReturnViolation if it returns false for the return value" do
        proxy = interface(get: { returns: ->(o) { o.include?('impossible') } }).proxy(Subject.new)
        expect { proxy.get }.to raise_error(TestInterface::ReturnViolation)
      end

    end

  end

  describe "arguments" do

    it "are allowed if uncontracted" do
      proxy = interface(set: { :returns => Object }).proxy(Subject.new)
      expect { proxy.set("new knowledge") }.to_not raise_error
    end

    it "are allowed if unconstrained" do
      proxy = interface(set: { :args => :any }).proxy(Subject.new)
      proxy.set("new knowledge")
      expect { proxy.set("new knowledge") }.to_not raise_error
    end

    describe "type" do

      it "is allowed if contracted for one argument" do
        proxy = interface(set: {args: String}).proxy(Subject.new)
        expect { proxy.set("new knowledge") }.to_not raise_error
      end

      it "raises a TestInterface::ArgumentViolation if uncontracted for one argument" do
        proxy = interface(set: {args: Numeric}).proxy(Subject.new)
        expect { proxy.set("new knowledge") }.to raise_error TestInterface::ArgumentViolation
      end

    end

    describe "types" do

      it "are allowed if each one is contracted" do
        proxy = interface(ignore: {args: [String, :any]}).proxy(Subject.new)
        expect { proxy.ignore("correct", "types") }.to_not raise_error
      end

      it "raise TestInterface::ArgumentViolation if not all contracted" do
        proxy = interface(ignore: {args: [:any, Numeric]}).proxy(Subject.new)
        expect { proxy.ignore("wrong", "types") }.to raise_error TestInterface::ArgumentViolation
      end

    end

    describe "count" do

      it "raises TestInterface::ArgumentViolation if too numerous" do
        proxy = interface(ignore: { args: Object }).proxy(Subject.new)
        expect { proxy.ignore("too", "many arguments") }.to raise_error TestInterface::ArgumentViolation
      end

      it "raises TestInterface::ArgumentViolation if too few" do
        proxy = interface(ignore: { args: [ String, String ] }).proxy(Subject.new)
        expect { proxy.ignore("too few arguments") }.to raise_error TestInterface::ArgumentViolation
      end

      it "raises TestInterface::ArgumentViolation if prohibited" do
        proxy = interface(get: { :args => :none }).proxy(Subject.new)
        expect { proxy.get("new knowledge") }.to raise_error TestInterface::ArgumentViolation
      end

      it "is allowed to be zero when prohibited" do
        proxy = interface(get: { :args => :none }).proxy(Subject.new)
        expect { proxy.get }.to_not raise_error
      end

    end

    describe "rule" do

      let(:rule)  { ->(a) { a.size == 1 and a.first == "new knowledge" } }
      let(:proxy) { interface(set: { args: rule }, :get => :allowed).proxy(Subject.new) }

      it "allows the arguments if it returns true for them" do
        proxy.set("new knowledge")
        proxy.get.should == "new knowledge"
      end

      it "raises TestInterface::ArgumentViolation it it returns false for them" do
        expect { proxy.set("old knowledge") }.to raise_error TestInterface::ArgumentViolation
      end

    end

  end

  describe "exceptions" do

    class TestExampleError < Exception; end

    let(:exploding_subject) do
      Subject.new.tap { |o| o.stub(:get).and_raise TestExampleError }
    end

    it "are allowed if uncontracted" do
      proxy = interface(get: {:args => :any}).proxy(exploding_subject)
      expect { proxy.get }.to raise_error TestExampleError
    end

    it "are allowed if unconstrained" do
      proxy = interface(get: {:exceptions => :any}).proxy(exploding_subject)
      expect { proxy.get }.to raise_error TestExampleError
    end

    it "are allowed if of contracted type" do
      proxy = interface(get: {exceptions: TestExampleError}).proxy(exploding_subject)
      expect { proxy.get }.to raise_error TestExampleError
    end

    it "raise TestInterface::ExceptionViolation if not of contracted type" do
      proxy = interface(get: {exceptions: ArgumentError}).proxy(exploding_subject)
      expect { proxy.get }.to raise_error TestInterface::ExceptionViolation
    end

    it "raises TestInterface::ExceptionViolation if prohibited" do
      proxy = interface(get: {:exceptions => :none}).proxy(exploding_subject)
      expect { proxy.get }.to raise_error TestInterface::ExceptionViolation
    end

    describe "rule" do

      it "allows an exception if it returns true for the exception" do
        rule = ->(e) { true }
        proxy = interface(get: {:exceptions => rule}).proxy(exploding_subject)
        expect { proxy.get }.to raise_error TestExampleError
      end

      it "raises TestInterface::ExceptionViolation it it returns false for the exception" do
        rule = ->(e) { false }
        proxy = interface(get: {:exceptions => rule}).proxy(exploding_subject)
        expect { proxy.get }.to raise_error TestInterface::ExceptionViolation
      end

    end

  end

end
