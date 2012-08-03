module TestInterface

  class Enforcer

    class MethodContract

      class ExceptionProcConstraint

        def initialize(rule)
          @rule = rule
        end

        def constrain(exception)
          @rule.call(exception) or raise TestInterface::ExceptionViolation
        end

      end

    end

  end

end

