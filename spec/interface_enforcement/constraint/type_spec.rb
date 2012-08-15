require 'spec_helper'

describe InterfaceEnforcement::Constraint::Type do

  context "for a class" do

    subject { InterfaceEnforcement::Constraint::Type.new(Set) }

    it 'allows the class' do
      subject.allows?(Set.new).should be_true
    end

    it 'allows its subclasses' do
      subject.allows?(SortedSet.new).should be_true
    end

    it 'does not allow its ancestors' do
      subject.allows?(Object.new).should be_false
    end

    it 'does not allow unrelated classes' do
      subject.allows?(String.new).should be_false
    end

  end

  context "for a module" do

    subject { InterfaceEnforcement::Constraint::Type.new(Enumerable) }

    it 'allows objects that include the module' do
      subject.allows?(Array.new).should be_true
    end

    it 'does not allow objects that do not include the module' do
      subject.allows?(Object.new).should be_false
    end

  end

end