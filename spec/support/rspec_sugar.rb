require 'test_interface'

module TestInterface
  module RspecSugar

    class Enforcement
      def initialize(interface)
        @interface = interface
      end

      def on(subject)
        @interface.proxy(subject)
      end
    end

    def enforce(contract)
      interface = TestInterface::Interface.new(contract)
      Enforcement.new(interface)
    end
  end
end
