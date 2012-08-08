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
      @subject = subject
      TestInterface::Proxy.new(self, @subject)
    end

    def each_method_name
      @contracts.each_key do |method|
        yield method
      end
    end

    def method_contract(method)
      @contracts[method]
    end

    private

    def add_method_contract(method, constraints)
      @contracts[method] = MethodContract.new(constraints)
    end

  end

end
