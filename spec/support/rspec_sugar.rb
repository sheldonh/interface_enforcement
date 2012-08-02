require 'test_interface'

module TestInterface
  module RspecSugar

    class Enforcement
      def initialize(enforcer)
        @enforcer = enforcer
      end

      def on(subject)
        @enforcer.wrap(subject)
      end
    end

    def enforce(contract)
      enforcer = TestInterface::Enforcer.new(contract)
      Enforcement.new(enforcer)
    end
  end
end
