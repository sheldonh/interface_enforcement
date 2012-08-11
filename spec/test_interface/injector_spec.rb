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

  include TestInterface::RspecSugar

  describe "method invocation" do

    it "is allowed on the subject if contracted" do
      subject = Subject.new
      interface(:get => :allowed, :set => :allowed).inject(subject)
      subject.set("new knowledge")
      subject.get.should eq("new knowledge")
    end

    it "raises a TestInterface::MethodViolation if uncontracted" do
      subject = Subject.new
      interface(:set => :allowed).inject(subject)
      expect { subject.get }.to raise_error TestInterface::MethodViolation
    end

    context "private methods" do

      it "raises an ArgumentError if contracted against a private method" do
        expect { interface(:private_method => :allowed).inject(Subject.new) }.to raise_error ArgumentError
      end

      it "raises an ArgumentError if contracted against a nonexistent method" do
        expect { interface(:nonexistent => :allowed).inject(Subject.new) }.to raise_error ArgumentError
      end

      it "does not prevent the subject's own access to its own private methods" do
        subject = Subject.new
        interface(:expose_secret => :allowed).inject(Subject.new)
        subject.expose_secret == "a secret"
      end

    end

  end

end