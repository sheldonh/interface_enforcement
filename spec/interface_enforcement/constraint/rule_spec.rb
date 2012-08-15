require 'spec_helper'

describe InterfaceEnforcement::Constraint::Rule do

  it 'allows an argument for which its callable is true' do
    subject = InterfaceEnforcement::Constraint::Rule.new ->(o) { o == :something }
    subject.allows?(:something).should be_true
  end

  it 'does not allow an argument for which its callable is false' do
    subject = InterfaceEnforcement::Constraint::Rule.new ->(o) { o.nil? }
    subject.allows?(:something).should be_false
  end

end