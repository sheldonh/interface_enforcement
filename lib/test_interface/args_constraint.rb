require 'test_interface/constraint'

module TestInterface

  module ArgsConstraint

    def self.build(specification)
      if specification.is_a?(Proc)
        Constraint::Rule.new(ArgumentViolation, specification)
      elsif specification == :none
        Constraint::None.new(ArgumentViolation)
      else
        Constraint::Enumeration.new(ArgumentViolation, specification)
      end
    end

  end

end
