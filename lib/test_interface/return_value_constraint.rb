require 'test_interface/constraint'

module TestInterface

  module ReturnValueConstraint

    def self.build(specification)
      if specification.is_a?(Proc)
        Constraint::Rule.new(ReturnViolation, specification)
      elsif specification.is_a?(Module)
        Constraint::Type.new(ReturnViolation, specification)
      else
        Constraint::Open.new
      end
    end

  end

end
