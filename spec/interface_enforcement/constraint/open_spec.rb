require 'spec_helper'

describe InterfaceEnforcement::Constraint::Open do

  it 'allows nil' do
    subject.allows?(nil).should be_true
  end

  it 'allows an enumerable' do
    subject.allows?([:some, :stuff]).should be_true
  end

  it 'allows a scalar' do
    subject.allows?(:something).should be_true
  end

end

