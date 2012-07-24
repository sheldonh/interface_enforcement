require 'spec_helper'

require 'interface_enforcer'

describe InterfaceEnforcer do

  let(:real_subject) {
    class Subject
      def ask; @knowledge || "the default"; end
      def tell(something); @knowledge = something; end
      private; def private_method; "a secret"; end
    end
    Subject.new
  }

  it "contracted methods are delegated to the subject" do
    subject = InterfaceEnforcer.new(:ask => :allowed, :tell => :allowed).attach(real_subject)
    subject.tell("new knowledge")
    subject.ask.should eq("new knowledge")
  end

  it "contracted methods honour subject privacy" do
    subject = InterfaceEnforcer.new(:private_method => :allowed).attach(real_subject)
    expect { subject.private_method }.to raise_error(NoMethodError)
  end

  it "uncontracted methods raise a method violation" do
    subject = InterfaceEnforcer.new(:demand => :allowed).attach(real_subject)
    expect { subject.ask }.to raise_error(InterfaceEnforcer::MethodViolation)
  end


  it "contracted return value types are allowed" do
    subject = InterfaceEnforcer.new(:ask => { :return => String }).attach(real_subject)
    subject.ask.should eq("the default")
  end

  it "uncontracted return value types raise a return violation" do
    subject = InterfaceEnforcer.new(:ask => { :return => Numeric }).attach(real_subject)
    expect { subject.ask }.to raise_error(InterfaceEnforcer::ReturnViolation)
  end

end
