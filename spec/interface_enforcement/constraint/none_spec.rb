require 'spec_helper'

describe InterfaceEnforcement::Constraint::None do

  it 'allows an empty enumerable' do
    subject.allows?([]).should be_true
  end

  it 'does not allow a populated enumerable' do
    subject.allows?([:something]).should be_false
  end

  it 'does not allow a non-enumerable' do
    subject.allows?(:something).should be_false
  end

end