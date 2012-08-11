require 'test_interface/injector'
require 'test_interface/method_contract'
require 'test_interface/proxy'

module TestInterface

  class Interface

    def initialize(contract)
      @contracts = {}
      contract.each do |method, constraints|
        add_method_contract(method, constraints)
      end
    end

    def proxy(subject)
      TestInterface::Proxy.new(self, subject)
    end

    def inject(subject)
      TestInterface::Injector.new(self).inject(subject)
    end

    # TODO push this privacy check into Enforcer, making it a runtime concern (to support dynamism)
    def ensure_valid_for_subject(subject)
      @contracts.each_key do |method|
        ensure_subject_responds(subject, method)
      end
    end

    def method_contract(method)
      @contracts[method]
    end

    private

    def add_method_contract(method, constraints)
      @contracts[method] = MethodContract.new(constraints)
    end

    def ensure_subject_responds(subject, method_name)
      if !subject.respond_to?(method_name)
        raise ArgumentError, "nonexistent or private method #{method_name} may not form part of an interface"
      end
    end

  end

end
