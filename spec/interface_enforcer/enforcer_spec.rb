require 'spec_helper'

require 'interface_enforcer'

describe InterfaceEnforcer do

  let(:real_subject) {
    class Subject
      def ask; @knowledge; end
      def tell(something); @knowledge = something; end
      private; def private_method; "a secret"; end
    end
    Subject.new
  }

  it "contracted methods are delegated to the subject" do
    subject = InterfaceEnforcer.new(:ask => :allowed, :tell => :allowed).attach(real_subject)
    subject.tell("the knowledge")
    subject.ask.should eq("the knowledge")
  end

  it "contracted methods honour subject privacy" do
    subject = InterfaceEnforcer.new(:private_method => :allowed).attach(real_subject)
    expect { subject.private_method }.to raise_error(NoMethodError)
  end

  it "uncontracted methods raise a method violation" do
    subject = InterfaceEnforcer.new(:demand => :allowed).attach(real_subject)
    expect { subject.ask }.to raise_error(InterfaceEnforcer::MethodViolation)
  end

end
