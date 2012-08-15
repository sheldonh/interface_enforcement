require 'spec_helper'

module InterfaceEnforcement

  describe Injector do

    let(:enforcer) { double }
    let(:interface) { double.as_null_object }
    let(:subject) { Subject.new }

    it 'redefines methods on the subject for delegation through an interface enforcer' do
      enforcer.should_receive(:enforce).with(:get, [], self).and_return :return_value
      Injector.new(interface, subject).with_enforcer(enforcer).inject
      subject.get.should == :return_value
    end

    it 'redefines methods on the subject for delegation to the subject' do
      subject.should_receive(:get).and_return :return_value
      Injector.new(interface, subject).inject
      subject.get.should == :return_value
    end

    it 'redefines protected methods' do
      enforcer.should_receive(:enforce)
      Injector.new(interface, subject).with_enforcer(enforcer).inject
      subject.send(:protected_method)
    end

    it 'does not redefine private methods' do
      enforcer.should_not_receive(:enforce)
      Injector.new(interface, subject).with_enforcer(enforcer).inject
      subject.send(:private_method)
    end

    it 'defaults to using an AliasedEnforcer' do
      AliasedEnforcer.should_receive(:new).with(interface, subject, 'interface_injected_')
        .and_return enforcer.as_null_object
      Injector.new(interface, subject).enforcer.should == enforcer
    end

    it 'provides an all in one utility method for injection' do
      Injector.should_receive(:new).with(interface, subject).and_return injector = double(Injector)
      injector.should_receive(:inject)
      Injector.inject(interface, subject)
    end

  end

end
