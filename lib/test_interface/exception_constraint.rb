require 'test_interface/constraint'

module TestInterface

  module ExceptionConstraint

    def self.build(specification)
      if specification.is_a?(Proc)
        Constraint::Rule.new(ExceptionViolation, specification)
      elsif specification == :none
        Constraint::None.new(ExceptionViolation)
      else
        Constraint::Type.new(ExceptionViolation, specification)
      end
    end

  end

end
