require 'interface_enforcement'

module InterfaceEnforcement
  module RspecSugar

    class Enforcement
      def initialize(interface)
        @interface = interface
      end

      def proxy(subject)
        @interface.proxy(subject)
      end

      def inject(subject)
        @interface.inject(subject)
      end
    end

    def interface(contract)
      interface = InterfaceEnforcement::Interface.new(contract)
      Enforcement.new(interface)
    end
  end
end
