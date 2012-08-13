module InterfaceEnforcement

  module Constraint

    class Rule

      def initialize(callable)
        @callable = callable
      end

      def constrain(o)
        @callable.call(o)
      end

    end

  end

end