require 'test_interface/constraint'

module TestInterface

  class Enforcer

    class MethodContract

      class ExceptionConstraint

        include Constraint

        def self.build(specification)
          if specification.is_a?(Proc)
            ExceptionProcConstraint.new specification
          elsif specification == :none
            ExceptionNoneConstraint.new
          else
            new(specification)
          end
        end

        def initialize(definition)
          @rule = type_constrained_rule(definition)
        end

        def constrain(exception)
          @rule.call(exception) or raise TestInterface::ExceptionViolation
        end

      end

    end

  end

end
