module TestInterface

  class Enforcer

    class MethodContract

      class ArgsConstraint

        include Constraint

        def initialize(specification)
          specification = [ specification ] unless specification.is_a?(Enumerable)
          @rules = specification.map { |c| type_constrained_rule(c) }
        end

        def allows?(args)
          args.each_with_index do |o, i|
            @rules[i].call(o) or break false
          end
        end

      end

    end

  end

end
