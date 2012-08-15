require 'spec_helper'

module InterfaceEnforcement

  describe MethodContract do

    class FakeConstraint
      def initialize(allows)
        @allows = allows
      end
      def allows?(args)
        @received = args
        @allows
      end
      attr_reader :received
    end

    def allow
      FakeConstraint.new(true)
    end

    def disallow
      FakeConstraint.new(false)
    end

    describe '.build(specification)' do

      it 'interprets :allowed as a completely unconstrained method' do
        builder = double(Constraint)
        builder.should_receive(:build_args_constraint).with :any
        builder.should_receive(:build_exception_constraint).with :any
        builder.should_receive(:build_return_value_constraint).with :any
        MethodContract.build(:allowed, builder)
      end

      it 'builds the specified constraints into the method contract' do
        builder = double(Constraint, :build_args_constraint => :args_constraint,
                                     :build_exception_constraint => :exception_constraint,
                                     :build_return_value_constraint => :return_value_constraint)
        subject = MethodContract.build(:allowed, builder)
        subject.args_constraint.should == :args_constraint
        subject.exception_constraint.should == :exception_constraint
        subject.return_value_constraint.should == :return_value_constraint
      end

    end

    describe '#allows_args?(a)' do

      it 'are delegated to the args constraint' do
        subject = MethodContract.new(args_constraint = allow, allow, allow)
        subject.allows_args?([:some, :args])
        args_constraint.received.should == [:some, :args]
      end

      it 'are allowed if the args constraint allows it' do
        subject = MethodContract.new(allow, allow, allow)
        subject.allows_args?([]).should be_true
      end

      it 'are disallows if the args constraint disallows it' do
        subject = MethodContract.new(disallow, allow, allow)
        subject.allows_args?([]).should be_false
      end

    end

    describe '#allows_exception?(e)' do

      it 'is delegated to the exception constraint' do
        subject = MethodContract.new(allow, exception_constraint = allow, allow)
        subject.allows_exception?(RuntimeError.new)
        exception_constraint.received.should == RuntimeError.new
      end

      it 'is allowed if the exception constraint allows it' do
        subject = MethodContract.new(allow, allow, allow)
        subject.allows_exception?(RuntimeError.new).should be_true
      end

      it 'is disallows if the exception constraint disallows it' do
        subject = MethodContract.new(allow, disallow, allow)
        subject.allows_exception?(RuntimeError.new).should be_false
      end

    end

    describe '#allows_return_value?(o)' do

      it 'is delegated to the return value constraint' do
        subject = MethodContract.new(allow, allow, return_value_constraint = allow)
        subject.allows_return_value?(:some => :value)
        return_value_constraint.received.should == {:some => :value}
      end

      it 'is allowed if the return value constraint allows it' do
        subject = MethodContract.new(allow, allow, allow)
        subject.allows_return_value?(:x).should be_true
      end

      it 'is disallows if the return value constraint disallows it' do
        subject = MethodContract.new(allow, allow, disallow)
        subject.allows_return_value?(:x).should be_false
      end

    end

  end

end



