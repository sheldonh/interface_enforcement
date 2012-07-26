module TestInterface

  class Enforcer

    class MethodContract

      module Constraint

        UNCONSTRAINED_TYPE = :any

        def type_constrained_rule(type)
          ->(o) { type.nil? or type == UNCONSTRAINED_TYPE or o.is_a?(type) }
        end

      end

    end

  end

end

require 'test_interface/return_value_constraint'
require 'test_interface/args_constraint'
