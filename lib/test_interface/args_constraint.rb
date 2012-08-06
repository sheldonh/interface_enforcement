require 'test_interface/constraint'

module TestInterface

  module ArgsConstraint

    def self.build(specification)
      if specification.is_a?(Proc)
        Constraint::Rule.new(ArgumentViolation, specification)
      elsif specification == :none
        Constraint::None.new(ArgumentViolation)
      elsif specification.is_a?(Enumerable)
        Constraint::Enumeration.new(ArgumentViolation, specification)
      elsif specification.is_a?(Module)
        Constraint::Enumeration.new(ArgumentViolation, [ specification ])
      else
        Constraint::Open.new
      end
    end

  end

end
