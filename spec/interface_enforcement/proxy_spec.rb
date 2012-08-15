require 'spec_helper'

module InterfaceEnforcement

  describe Proxy do

    let(:interface) { double }
    let(:subject) { double }

    it 'delegates method calls through an interface enforcer' do
      enforcer = double.tap { |o| o.should_receive(:enforce).with(:get, [], self).and_return :return_value }
      enforcer_type = double.tap { |o| o.should_receive(:new).with(interface, subject).and_return enforcer }
      proxy = Proxy.proxy(interface, subject, enforcer_type)
      proxy.get.should == :return_value
    end

  end

end
