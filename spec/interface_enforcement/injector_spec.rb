require 'spec_helper'

module InterfaceEnforcement

  describe Injector do

    let(:interface) { double.as_null_object }
    let(:subject) { Subject.new }

    it 'redefines methods on the subject for delegation through an interface enforcer' do
      enforcer_type, enforcer = double, double
      enforcer_type.should_receive(:new).with(interface, subject, 'interface_injected_').and_return enforcer
      enforcer.should_receive(:enforce).with(:get, [], self).and_return :return_value
      Injector.inject(interface, subject, enforcer_type)
      subject.get.should == :return_value
    end

    it 'redefines methods on the subject for delegation to the subject' do
      subject.should_receive(:get).and_return :return_value
      Injector.inject(interface, subject)
      subject.get.should == :return_value
    end

    it 'redefines protected methods' do
      enforcer_type, enforcer = double, double
      enforcer_type.should_receive(:new).with(interface, subject, 'interface_injected_').and_return enforcer
      enforcer.should_receive(:enforce)
      Injector.inject(interface, subject, enforcer_type)
      subject.send(:protected_method)
    end

    it 'does not redefine private methods on the subject' do
      enforcer_type, enforcer = double, double
      enforcer_type.should_receive(:new).with(interface, subject, 'interface_injected_').and_return enforcer
      enforcer.should_not_receive(:enforce)
      Injector.inject(interface, subject, enforcer_type)
      subject.send(:private_method)
    end

  end

end
