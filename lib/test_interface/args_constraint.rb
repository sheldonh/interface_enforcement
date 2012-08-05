require 'test_interface/constraint'

module TestInterface

  module ArgsConstraint

    def self.build(specification)
      if specification.is_a?(Proc)
        TestInterface::Constraint::Rule.new(TestInterface::ArgumentRuleViolation, specification)
      elsif specification == :none
        TestInterface::Constraint::None.new(TestInterface::ArgumentCountViolation)
      else
        TestInterface::Constraint::Enumeration.new(TestInterface::ArgumentTypeViolation, specification)
      end
    end

  end

end
