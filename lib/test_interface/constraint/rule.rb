module TestInterface

  module Constraint

    class Rule

      def initialize(exception, callable)
        @exception = exception
        @callable = callable
      end

      def constrain(o)
        raise @exception unless @callable.call(o)
      end

    end

  end

end