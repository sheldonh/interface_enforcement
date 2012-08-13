require 'interface_enforcement/injector'
require 'interface_enforcement/method_contract'
require 'interface_enforcement/proxy'

module InterfaceEnforcement

  class Interface

    def initialize(contract)
      @contracts = {}
      contract.each do |method, constraints|
        add_method_contract(method, constraints)
      end
    end

    def proxy(subject)
      InterfaceEnforcement::Proxy.new(self, subject)
    end

    def inject(subject)
      InterfaceEnforcement::Injector.new(self).inject(subject)
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
