require 'spec_helper'

describe InterfaceEnforcement::Proxy do

  include InterfaceEnforcement::RspecSugar

  describe "method invocation" do

    it "is delegated to the subject if contracted" do
      proxy = interface(:get => :allowed, :set => :allowed).proxy(Subject.new)
      proxy.set("new knowledge")
      proxy.get.should eq("new knowledge")
    end

    it "raises a InterfaceEnforcement::MethodViolation if uncontracted" do
      proxy = interface(:set => :allowed).proxy(Subject.new)
      expect { proxy.get }.to raise_error InterfaceEnforcement::MethodViolation
    end

    context "nonexistent methods" do

      it "raise a NoMethodError" do
        proxy = interface({}).proxy(Subject.new)
        expect { proxy.nonexistent }.to raise_error NoMethodError
      end

    end

    context "private methods" do

      it "raise a NoMethodError if contracted" do
        proxy = interface(:private_method => :allowed).proxy(Subject.new)
        expect { proxy.private_method }.to raise_error NoMethodError
      end

      it "raise a NoMethodError if uncontracted" do
        proxy = interface(:get => :allowed).proxy(Subject.new)
        expect { proxy.private_method }.to raise_error NoMethodError
      end

      it "are allowed when called by the subject" do
        proxy = interface(:expose_secret => :allowed).proxy(Subject.new)
        proxy.expose_secret == "a secret"
      end

    end

    context "protected methods" do

      it "does not prevent legitimate access to the subject's protected methods" do
        proxy = interface(:protected_method => :allowed).proxy(Subject.new)
        Descendant.new(proxy).shared_secret.should == "a shared secret"
      end

      it "does not allow illegitimate access to the subject's protected methods" do
        proxy = interface(:protected_method => :allowed).proxy(Subject.new)
        expect { NonDescendant.new(proxy).shared_secret }.to raise_error NoMethodError
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

      it "raises InterfaceEnforcement::ReturnViolation if of uncontracted type" do
        proxy = interface(get: { returns: Numeric }).proxy(Subject.new)
        expect { proxy.get }.to raise_error(InterfaceEnforcement::ReturnViolation)
      end

    end

    describe "rule" do

      it "allows the return value if it returns true for the return value" do
        proxy = interface(get: { returns: ->(o) { o.include?('default') } }).proxy(Subject.new)
        proxy.get.should eq("the default")
      end

      it "raises InterfaceEnforcement::ReturnViolation if it returns false for the return value" do
        proxy = interface(get: { returns: ->(o) { o.include?('impossible') } }).proxy(Subject.new)
        expect { proxy.get }.to raise_error(InterfaceEnforcement::ReturnViolation)
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
      expect { proxy.set("new knowledge") }.to_not raise_error
    end

    describe "type" do

      it "is allowed if contracted for one argument" do
        proxy = interface(set: {args: String}).proxy(Subject.new)
        expect { proxy.set("new knowledge") }.to_not raise_error
      end

      it "raises a InterfaceEnforcement::ArgumentViolation if uncontracted for one argument" do
        proxy = interface(set: {args: Numeric}).proxy(Subject.new)
        expect { proxy.set("new knowledge") }.to raise_error InterfaceEnforcement::ArgumentViolation
      end

    end

    describe "types" do

      it "are allowed if each one is contracted" do
        proxy = interface(ignore: {args: [String, :any]}).proxy(Subject.new)
        expect { proxy.ignore("correct", "types") }.to_not raise_error
      end

      it "raise InterfaceEnforcement::ArgumentViolation if not all contracted" do
        proxy = interface(ignore: {args: [:any, Numeric]}).proxy(Subject.new)
        expect { proxy.ignore("wrong", "types") }.to raise_error InterfaceEnforcement::ArgumentViolation
      end

    end

    describe "count" do

      it "raises InterfaceEnforcement::ArgumentViolation if too numerous" do
        proxy = interface(ignore: { args: Object }).proxy(Subject.new)
        expect { proxy.ignore("too", "many arguments") }.to raise_error InterfaceEnforcement::ArgumentViolation
      end

      it "raises InterfaceEnforcement::ArgumentViolation if too few" do
        proxy = interface(ignore: { args: [ String, String ] }).proxy(Subject.new)
        expect { proxy.ignore("too few arguments") }.to raise_error InterfaceEnforcement::ArgumentViolation
      end

      it "raises InterfaceEnforcement::ArgumentViolation if prohibited" do
        proxy = interface(get: { :args => :none }).proxy(Subject.new)
        expect { proxy.get("new knowledge") }.to raise_error InterfaceEnforcement::ArgumentViolation
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

      it "raises InterfaceEnforcement::ArgumentViolation it it returns false for them" do
        expect { proxy.set("old knowledge") }.to raise_error InterfaceEnforcement::ArgumentViolation
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

    it "raise InterfaceEnforcement::ExceptionViolation if not of contracted type" do
      proxy = interface(get: {exceptions: ArgumentError}).proxy(exploding_subject)
      expect { proxy.get }.to raise_error InterfaceEnforcement::ExceptionViolation
    end

    it "raises InterfaceEnforcement::ExceptionViolation if prohibited" do
      proxy = interface(get: {:exceptions => :none}).proxy(exploding_subject)
      expect { proxy.get }.to raise_error InterfaceEnforcement::ExceptionViolation
    end

    describe "rule" do

      it "allows an exception if it returns true for the exception" do
        rule = ->(e) { true }
        proxy = interface(get: {:exceptions => rule}).proxy(exploding_subject)
        expect { proxy.get }.to raise_error TestExampleError
      end

      it "raises InterfaceEnforcement::ExceptionViolation it it returns false for the exception" do
        rule = ->(e) { false }
        proxy = interface(get: {:exceptions => rule}).proxy(exploding_subject)
        expect { proxy.get }.to raise_error InterfaceEnforcement::ExceptionViolation
      end

    end

  end

end
