module TestInterface

  class Enforcer

    class MethodContract

      class ReturnValueConstraint

        include Constraint

        def initialize(definition)
          if definition.is_a?(Proc)
            @rule = definition
          else
            @rule = type_constrained_rule(definition)
          end
        end

        def allows?(return_value)
          @rule.call(return_value)
        end

      end

    end

  end

end
