require 'spec_helper'

module InterfaceEnforcement

  describe Injector do

    let(:enforcer_class) { double.tap { |o| o.stub(:new).and_return enforcer } }
    let(:enforcer) { double }
    let(:interface) { double.as_null_object }
    let(:subject) { Subject.new }

    it 'redefines methods on the subject for delegation through an interface enforcer' do
      enforcer_class.should_receive(:new).with(interface, subject, 'interface_injected_').and_return enforcer
      enforcer.should_receive(:enforce).with(:get, [], self).and_return :return_value
      Injector.for(interface).with_enforcer_class(enforcer_class).apply(subject)
      subject.get.should == :return_value
    end

    it 'redefines protected methods' do
      enforcer.should_receive(:enforce)
      Injector.for(interface).with_enforcer_class(enforcer_class).apply(subject)
      subject.send(:protected_method)
    end

    it 'does not redefine private methods' do
      enforcer.should_not_receive(:enforce)
      Injector.for(interface).with_enforcer_class(enforcer_class).apply(subject)
      subject.send(:private_method)
    end

    it 'defaults to using an AliasedEnforcer' do
      Injector.new(interface, subject).enforcer_class.should == AliasedEnforcer
    end

    it 'provides an all in one utility method for injection' do
      Injector.should_receive(:new).with(interface, subject).and_return injector = double(Injector)
      injector.should_receive(:inject)
      Injector.inject(interface, subject)
    end

    describe 'application' do

      it 'can be applied to a subject by an interface' do
        enforcer.should_receive(:enforce)
        Injector.for(interface).with_enforcer_class(enforcer_class).apply(subject).get
      end

    end

  end

end
