module TestInterface

  class Enforcer

    class MethodContract

      def initialize(constraints)
        unless constraints == :allowed
          set_args_rules(constraints[:args])
          set_return_value_rule(constraints[:returns])
        end
      end

      def valid_args?(args)
        return true unless @args_rules
        args.each_with_index do |o, i|
          @args_rules[i].call(o) or break false
        end
      end

      def valid_return_value?(return_value)
        return true unless @return_value_rule
        @return_value_rule.call(return_value)
      end

      private

      def set_args_rules(constraints)
        if constraints.is_a?(Module)
          @args_rules = args_rules [ constraints ]
        elsif constraints.is_a?(Enumerable)
          @args_rules = args_rules constraints
        end
      end

      def args_rules(constraints)
        constraints.map { |c| type_constrained_rule(c) }
      end

      def set_return_value_rule(constraint)
        if constraint.is_a?(Proc)
          @return_value_rule = constraint
        elsif constraint.is_a?(Module)
          @return_value_rule = type_constrained_rule(constraint)
        end
      end

      def type_constrained_rule(constraint)
        ->(o) { constraint == :any or o.is_a?(constraint) }
      end

    end

  end

end
