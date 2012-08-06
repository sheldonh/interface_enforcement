module TestInterface

  module Constraint

    class Enumeration

      def initialize(enumeration)
        @rules = enumeration.map { |c| Constraint.build(c, :type, :any) }
      end

      def constrain(enum)
        all_rules_apply?(enum)
      end

      private

      def all_rules_apply?(enum)
        if @rules.size == enum.size
          enum.each_with_index do |o, i|
            return false unless @rules[i].constrain(o)
          end
        end
      end

    end

  end

end