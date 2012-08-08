require 'test_interface'

module TestInterface
  module RspecSugar

    class Enforcement
      def initialize(interface)
        @interface = interface
      end

      def proxy(subject)
        @interface.proxy(subject)
      end
    end

    def interface(contract)
      interface = TestInterface::Interface.new(contract)
      Enforcement.new(interface)
    end
  end
end
