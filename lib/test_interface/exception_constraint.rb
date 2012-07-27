module TestInterface

  class Enforcer

    class MethodContract

      class ExceptionConstraint

        include Constraint

        def self.build(specification)
          new(specification)
        end

        def initialize(definition)
          if definition.nil?
            @rule = ->(o) { false }
          elsif definition == :any
            @rule = ->(o) { true }
          else
            @rule = type_constrained_rule(definition)
          end
        end

        def constrain(exception)
          @rule.call(exception) or raise TestInterface::ExceptionViolation
        end

      end

    end

  end

end
