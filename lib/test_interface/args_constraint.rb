require 'test_interface/constraint'

module TestInterface

  class Enforcer

    class MethodContract

      class ArgsConstraint

        include Constraint

        def self.build(specification)
          if specification.is_a?(Proc)
            ArgsProcConstraint.new(specification)
          elsif specification == :none
            ArgsNoneConstraint.new
          else
            ArgsEnumerableConstraint.new(specification)
          end
        end

        def initialize(specification)
          set_constraints(specification) unless unconstrained?(specification)
        end

        def constrain(args)
          constrain_args(args)
        end

        private

        def unconstrained?(specification)
          specification.nil? or specification == UNCONSTRAINED_TYPE
        end

        def set_constraints; raise NotImplementedError; end
        def constrain_args(args); raise NotImplementedError; end

      end

    end

  end

end
