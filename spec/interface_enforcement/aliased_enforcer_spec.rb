require 'spec_helper'

module InterfaceEnforcement

  describe AliasedEnforcer do

    it_behaves_like 'an interface enforcer'

    let(:interface) { double(Interface).as_null_object }
    let(:access_control) { double(AccessControl).as_null_object }
    let(:subject) { double.tap { |o| o.should_receive(:prefixed_get).and_return "the value" } }

    it 'adds a prefix to the method it passes to the configured access control' do
      access_control.should_receive(:subject_allows_sender?).with(subject, self, :prefixed_get).and_return true
      enforcer = AliasedEnforcer.new(interface, subject, "prefixed_", access_control)
      enforcer.enforce(:get, [], self)
    end

    it 'adds a prefix to the method it delegates the subject' do
      enforcer = AliasedEnforcer.new(interface, subject, "prefixed_", access_control)
      enforcer.enforce(:get, [], self).should == "the value"
    end
  end

end