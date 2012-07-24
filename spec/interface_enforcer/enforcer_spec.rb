require 'spec_helper'
require 'ostruct'

require 'interface_enforcer'

describe InterfaceEnforcer do

  let(:real_subject) { OpenStruct.new(:request => "a response") }

  it "are delegated to the subject" do
    subject = InterfaceEnforcer.new(:request => :allowed).attach(real_subject)
    subject.request.should eq("a response")
  end

  it "raises a method violation for uncontracted methods" do
    subject = InterfaceEnforcer.new(:demand => :allowed).attach(real_subject)
    expect { subject.request }.to raise_error(InterfaceEnforcer::MethodViolation)
  end

end
