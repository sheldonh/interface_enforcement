module TestInterface

  class Enforcer

    class MethodContract

      class ArgsNoneConstraint < ArgsConstraint

        def initialize
        end

        private

        def constrain_args(args)
          raise TestInterface::ArgumentCountViolation
        end

      end

    end

  end

end
