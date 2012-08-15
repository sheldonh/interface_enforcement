require 'spec_helper'

module InterfaceEnforcement

  describe Constraint do

    it 'raises ArgumentError for an unknown strategy' do
      expect { Constraint.build(:none, :none, :rubbish, :any) }
        .to raise_error ArgumentError, /unknown.*strategy/
    end

    it 'raises ArgumentError if all strategies gave up' do
      expect { Constraint.build(:rubbish, :any) }
        .to raise_error ArgumentError, /all strategies gave up/
    end

    it 'for strategy :any builds an Open constraint if the specification is nil' do
      Constraint.build(nil, :any).should be_a InterfaceEnforcement::Constraint::Open
    end

    it 'for strategy :any builds an Open constraint if the specification is :any' do
      Constraint.build(:any, :any).should be_a InterfaceEnforcement::Constraint::Open
    end

    it 'for strategy :enum builds an Enumeration constraint if the specification is an Enumerable' do
      Constraint.build([], :enum).should be_a InterfaceEnforcement::Constraint::Enumeration
    end

    it 'for strategy :enum_of_one builds an Enumeration constraint if the specification is a Module' do
      Constraint.build(Object, :enum_of_one).should be_a InterfaceEnforcement::Constraint::Enumeration
    end

    it 'for strategy :none builds a None constraint if the specification is :none' do
      Constraint.build(:none, :none).should be_a InterfaceEnforcement::Constraint::None
    end

    it 'for strategy :rule builds a Rule constraint if the specification is a Proc' do
      Constraint.build(Proc.new {}, :rule).should be_a InterfaceEnforcement::Constraint::Rule
    end

    it 'for strategy :type builds a Type constraint if the specification is a Module' do
      Constraint.build(Object, :type).should be_a InterfaceEnforcement::Constraint::Type
    end

    it 'for multiple applicable strategies builds per the first in the list' do
      Constraint.build(Module, :none, :enum_of_one, :type).should be_a InterfaceEnforcement::Constraint::Enumeration
      Constraint.build(Module, :none, :type, :enum_of_one).should be_a InterfaceEnforcement::Constraint::Type
    end

    it 'builds args constraints with strategy list :rule, :none, :enum, :enum_of_one, :any' do
      strategies = [:rule, :none, :enum, :enum_of_one, :any]
      Constraint::Builder.should_receive(:new).with(*strategies).and_return double.as_null_object
      Constraint.build_args_constraint(Module)
    end

    it 'builds return value constraints with strategy list :rule, :type, :any' do
      strategies = [:rule, :type, :any]
      Constraint::Builder.should_receive(:new).with(*strategies).and_return double.as_null_object
      Constraint.build_return_value_constraint(Module)
    end

    it 'builds return value constraints with strategy list :rule, :none, :type, :any' do
      strategies = [:rule, :none, :type, :any]
      Constraint::Builder.should_receive(:new).with(*strategies).and_return double.as_null_object
      Constraint.build_exception_constraint(Module)
    end

  end

end