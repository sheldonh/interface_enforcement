require 'test_interface/constraint'

module TestInterface

  module ReturnValueConstraint

    def self.build(specification)
      if specification.is_a?(Proc)
        Constraint::Rule.new(ReturnViolation, specification)
      else
        Constraint::Type.new(ReturnViolation, specification)
      end
    end

  end

end
