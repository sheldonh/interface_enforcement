module TestInterface

  class Enforcer

    class MethodContract

      class ReturnValueConstraint

        include Constraint

        def self.build(specification)
          new(specification)
        end

        def initialize(definition)
          if definition.is_a?(Proc)
            @rule = definition
          else
            @rule = type_constrained_rule(definition)
          end
        end

        def constrain(return_value)
          @rule.call(return_value) or raise TestInterface::ReturnViolation
        end

      end

    end

  end

end
