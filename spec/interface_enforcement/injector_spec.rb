require 'spec_helper'

describe InterfaceEnforcement::Injector do

  include InterfaceEnforcement::RspecSugar

  describe "method invocation" do

    it "is allowed on the subject if contracted" do
      subject = Subject.new
      interface(:get => :allowed, :set => :allowed).inject(subject)
      subject.set("new knowledge")
      subject.get.should eq("new knowledge")
    end

    it "raises a InterfaceEnforcement::MethodViolation if uncontracted" do
      subject = Subject.new
      interface(:set => :allowed).inject(subject)
      expect { subject.get }.to raise_error InterfaceEnforcement::MethodViolation
    end

    context "nonexistent methods" do

      it "raise a NoMethodError" do
        subject = Subject.new
        interface(:nonexistent => :allowed).inject(subject)
        expect { subject.nonexistent }.to raise_error NoMethodError
      end

    end

    context "private methods" do

      it "raise a NoMethodError if contracted" do
        subject = Subject.new
        interface(:private_method => :allowed).inject(subject)
        expect { subject.private_method }.to raise_error NoMethodError
      end

      it "raise a NoMethodError if uncontracted" do
        subject = Subject.new
        interface(:get => :allowed).inject(subject)
        expect { subject.private_method }.to raise_error NoMethodError
      end

      it "does not prevent the subject's own access to its own private methods" do
        subject = Subject.new
        interface(:expose_secret => :allowed).inject(subject)
        subject.expose_secret.should == "a secret"
      end

    end

    context "protected methods" do

      it "does not prevent legitimate access to the subject's protected methods" do
        subject = Subject.new
        interface(:protected_method => :allowed).inject(subject)
        Descendant.new(subject).shared_secret.should == "a shared secret"
      end

      it "does not allow illegitimate access to the subject's protected methods" do
        subject = Subject.new
        interface(:protected_method => :allowed).proxy(subject)
        expect { NonDescendant.new(subject).shared_secret }.to raise_error NoMethodError
      end

    end

  end

  describe "return values" do

    it "are allowed if uncontracted" do
      subject = Subject.new
      interface(get: { :args => :any }).inject(subject)
      subject.get.should eq("the default")
    end

    it "are allowed if unconstrained" do
      subject = Subject.new
      interface(get: { :returns => :any }).inject(subject)
      subject.get.should eq("the default")
    end

  end

  describe "arguments" do

    it "are allowed if uncontracted" do
      subject = Subject.new
      interface(set: { :returns => Object }).inject(subject)
      expect { subject.set("new knowledge") }.to_not raise_error
    end

    it "are allowed if unconstrained" do
      subject = Subject.new
      interface(set: { :args => :any }).proxy(subject)
      expect { subject.set("new knowledge") }.to_not raise_error
    end

  end

  describe "exceptions" do

    class TestExampleError < Exception; end

    let(:exploding_subject) do
      Subject.new.tap { |o| o.stub(:get).and_raise TestExampleError }
    end

    it "are allowed if uncontracted" do
      interface(get: {:args => :any}).inject(exploding_subject)
      expect { exploding_subject.get }.to raise_error TestExampleError
    end

    it "are allowed if unconstrained" do
      interface(get: {:exceptions => :any}).inject(exploding_subject)
      expect { exploding_subject.get }.to raise_error TestExampleError
    end

  end

end
