module TestInterface

  class Enforcer

    class MethodContract

      class ArgsConstraint

        include Constraint

        def initialize(specification)
          set_constraints(specification) unless unconstrained?(specification)
        end

        def constrain(args)
          constrain_argument_count(args.size)
          constrain_args(args)
        end

        private

        def unconstrained?(specification)
          specification.nil? or specification == UNCONSTRAINED_TYPE
        end

        def set_constraints(specification)
          specification = [ specification ] unless specification.is_a?(Enumerable)
          @rules = specification.map { |c| type_constrained_rule(c) }
          @constrained_argument_count = specification.size
        end

        def constrain_argument_count(actual)
          if @constrained_argument_count && @constrained_argument_count != actual
            raise ArgumentCountViolation.new "wrong number of arguments (#{actual} for #{@constrained_argument_count})"
          end
        end

        def constrain_args(args)
          if @rules
            args.each_with_index do |o, i|
              @rules[i].call(o) or raise ArgumentTypeViolation
            end
          end
        end

      end

    end

  end

end
