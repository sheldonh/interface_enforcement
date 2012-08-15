require 'spec_helper'

describe InterfaceEnforcement::Constraint::Enumeration do

  context 'enumerable size' do

    let(:subject) { InterfaceEnforcement::Constraint::Enumeration.new [Object, Object] }

    it 'disallows an enumerable that is too small' do
      subject.allows?([:too_few_things]).should be_false
    end

    it 'disallows an enumerable that is too large' do
      subject.allows?([:too, :many, :things]).should be_false
    end

    it 'allows an enumerable of the right size' do
      subject.allows?([:two, :things]).should be_true
    end

  end

  context 'enumerated types' do

    let(:subject) { InterfaceEnforcement::Constraint::Enumeration.new [Symbol, :any] }

    it 'disallows enumerations with at least one mismatched type' do
      subject.allows?([Object.new, Object.new]).should be_false
    end

    it 'allows enumerations whose types all match its own' do
      subject.allows?([:symbol, Object.new]).should be_true
    end

    it 'allows one or more elements to be unconstrained' do
      subject.allows?([:symbol, nil]).should be_true
      subject.allows?([:symbol, 4]).should be_true
      subject.allows?([:symbol, "Anything"]).should be_true
    end

  end

end