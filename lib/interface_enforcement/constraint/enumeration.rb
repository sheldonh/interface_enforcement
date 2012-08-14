module InterfaceEnforcement

  module Constraint

    class Enumeration

      def initialize(enumeration)
        @rules = enumeration.map { |c| Constraint.build(c, :type, :any) }
      end

      def allows?(enum)
        @enum = enum
        enumeration_size_correct? and all_rules_apply?
      end

      private

      def enumeration_size_correct?
        @rules.size == @enum.size
      end

      def all_rules_apply?
        @enum.each_with_index do |o, i|
          return false unless @rules[i].allows?(o)
        end
      end

    end

  end

end