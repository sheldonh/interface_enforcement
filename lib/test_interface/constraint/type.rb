module TestInterface

  module Constraint

    class Type

      def initialize(type)
        @type = type
      end

      def constrain(o)
        o.is_a?(@type)
      end

    end

  end

end