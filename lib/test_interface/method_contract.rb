module TestInterface

  class Enforcer

    class MethodContract

      def initialize(constraints)
        if constraints == :allowed
          @returns = unconstrained_rule
        else
          @returns = constraints[:returns]
        end
      end

      def valid_return_value?(return_value)
        return_value_rule.call(return_value)
      end

      private

      def return_value_rule
        if @returns.is_a?(Proc)
          @returns
        else
          constrained_return_type_rule
        end
      end

      def constrained_return_type_rule
        ->(o) { o.is_a?(@returns) }
      end

      def unconstrained_rule
        ->(o) { true }
      end

    end

  end

end
