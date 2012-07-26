module TestInterface

  class Enforcer

    class MethodContract

      class ArgsProcConstraint < ArgsConstraint

        private

        def set_constraints(rule)
          @rule = rule
        end

        def constrain_args(args)
          @rule.call(args)
        end

      end

    end

  end

end
