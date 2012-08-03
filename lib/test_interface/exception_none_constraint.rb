module TestInterface

  class Enforcer

    class MethodContract

      class ExceptionNoneConstraint

        def constrain(*args)
          raise TestInterface::ExceptionViolation
        end

      end

    end

  end

end

