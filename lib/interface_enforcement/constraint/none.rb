module InterfaceEnforcement

  module Constraint

    class None

      def constrain(o)
        nothing_received?(o)
      end

      private

      def nothing_received?(o)
        o.respond_to?(:empty?) and o.empty?
      end

    end

  end

end