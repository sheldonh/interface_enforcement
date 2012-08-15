require 'interface_enforcement/injector'
require 'interface_enforcement/method_contract'
require 'interface_enforcement/proxy'

module InterfaceEnforcement

  class Interface

    # TODO deject
    def self.build(specification, method_contract_builder = MethodContract)
      method_contracts = build_method_contracts(specification, method_contract_builder)
      new(method_contracts)
    end

    def initialize(contracts)
      @contracts = contracts
    end

    def proxy(subject, proxy_type = Proxy)
      proxy_type.proxy(self, subject)
    end

    def inject(subject, injector_type = Injector)
      injector_type.inject(self, subject)
      subject
    end

    def method_contracted?(method)
      @contracts.include?(method)
    end

    def allows_args?(method, args)
      @contracts[method].allows_args?(args)
    end

    def allows_return_value?(method, return_value)
      @contracts[method].allows_return_value?(return_value)
    end

    def allows_exception?(method, exception)
      @contracts[method].allows_exception?(exception)
    end

    private

    def self.build_method_contracts(specification, method_contract_builder)
      specification.inject({}) { |m, (k, v)| m[k] = method_contract_builder.build(v); m }
    end

  end

end
