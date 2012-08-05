require 'test_interface/constraint'

module TestInterface

  module ExceptionConstraint

    def self.build(specification)
      if specification.is_a?(Proc)
        TestInterface::Constraint::Rule.new(TestInterface::ExceptionViolation, specification)
      elsif specification == :none
        TestInterface::Constraint::None.new(TestInterface::ExceptionViolation)
      else
        TestInterface::Constraint::Type.new(TestInterface::ExceptionViolation, specification)
      end
    end

  end

end
