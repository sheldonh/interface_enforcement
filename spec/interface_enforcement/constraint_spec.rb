require 'spec_helper'

describe InterfaceEnforcement::Constraint do

  describe ".build(specification, *strategies)" do

    it "raises ArgumentError for an unknown strategy" do
      expect { InterfaceEnforcement::Constraint.build(String, :none, :rubbish, :any) }
        .to raise_error ArgumentError, /unknown.*strategy/
    end

    it "raises ArgumentError if all strategies gave up" do
      expect { InterfaceEnforcement::Constraint.build(:rubbish, :any) }
        .to raise_error ArgumentError, /all strategies gave up/
    end

  end

end