module TestInterface

  module Constraint

    class Type

      def initialize(exception, type)
        @exception = exception
        @type = type
      end

      def constrain(o)
        raise @exception unless o.is_a?(@type)
      end

    end

  end

end