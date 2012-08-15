require 'spec_helper'

module InterfaceEnforcement

  describe Proxy do

    let(:enforcer) { double }
    let(:interface) { double.as_null_object }
    let(:subject) { Subject.new }

    it 'delegates method calls through an interface enforcer' do
      enforcer.should_receive(:enforce).with(:get, [], self).and_return :return_value
      proxy = Proxy.proxy(interface, subject).with_enforcer(enforcer)
      proxy.get.should == :return_value
    end

    it 'defaults to using an Enforcer' do
      Enforcer.should_receive(:new).with(interface, subject).and_return enforcer.as_null_object
      Proxy.proxy(interface, subject).enforcer.should == enforcer
    end

  end

end
