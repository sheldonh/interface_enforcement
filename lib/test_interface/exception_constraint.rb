require 'test_interface/constraint'

module TestInterface

  module ExceptionConstraint

    def self.build(specification)
      if specification.is_a?(Proc)
        Constraint::Rule.new(ExceptionViolation, specification)
      elsif specification == :none
        Constraint::None.new(ExceptionViolation)
      elsif specification.is_a?(Module)
        Constraint::Type.new(ExceptionViolation, specification)
      else
        Constraint::Open.new
      end
    end

  end

end
