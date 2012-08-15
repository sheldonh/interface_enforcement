require 'spec_helper'
require 'ostruct'

module InterfaceEnforcement

  describe Interface do

    let(:allowed) { double(Constraint::Open).as_null_object }
    let(:disallowed) { NaySayer.new }

    it 'indicates when a method is contracted' do
      interface = Interface.new(:get => allowed)
      interface.method_contracted?(:get).should be_true
    end

    it 'indicates when a method is not contracted' do
      interface = Interface.new({})
      interface.method_contracted?(:get).should be_false
    end

    it 'indicates when args are allowed by a method contract' do
      interface = Interface.new(:get => allowed)
      interface.allows_args?(:get, []).should be_true
    end

    it 'indicates when args are disallowed by a method contract' do
      interface = Interface.new(:get => disallowed)
      interface.allows_args?(:get, []).should be_false
    end

    it 'indicates when a return value is allowed by a method contract' do
      interface = Interface.new(:get => allowed)
      interface.allows_return_value?(:get, Object).should be_true
    end

    it 'indicates when a return value is disallowed by a method contract' do
      interface = Interface.new(:get => disallowed)
      interface.allows_return_value?(:get, Object).should be_false
    end

    it 'indicates when an exception is allowed by a method contract' do
      interface = Interface.new(:get => allowed)
      interface.allows_exception?(:get, RuntimeError).should be_true
    end

    it 'indicates when an exception is disallowed by a method contract' do
      interface = Interface.new(:get => disallowed)
      interface.allows_exception?(:get, RuntimeError).should be_false
    end

    it 'can provide a proxy that enforces it on a subject' do
      subject = Object.new
      interface = Interface.new(:get => allowed)
      proxy_type = double.tap { |o| o.should_receive(:proxy).with(interface, subject).and_return :a_proxy }
      interface.proxy(subject, proxy_type).should == :a_proxy
    end

    # Yuk! rabbit holing?
    # TODO Interface.apply(o) to proxy an object, but Interface.inject(c) to alias initialize on a class
    # This would get rid of a dependency and provide symmetry
    it 'can be applied to a subject by an applicator' do
      subject = Object.new
      applicator, applicator_class = double, double
      interface = Interface.new(:get => allowed).with_applicator(applicator_class)

      applicator_class.should_receive(:for).with(interface).and_return applicator
      applicator.should_receive(:apply).with(subject).and_return :injected_subject
      interface.apply(subject).should == :injected_subject
    end

    describe '.build(specification)' do

      it 'creates an interface for the method contracts specified' do
        (builder = double).should_receive(:build).with(:allowed).and_return(first = double, second = double)
        Interface.should_receive(:new).with(:first => first, :second => second)
        Interface.build({:first => :allowed, :second => :allowed}, builder)
      end

    end

  end

end