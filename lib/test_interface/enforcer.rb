require 'test_interface/method_contract'

module TestInterface

  class Enforcer

    def initialize(contract)
      @contracts = contract.inject({}) do |memo, (method, constraints)|
        memo[method] = MethodContract.new(constraints)
        memo
      end
    end

    def wrap(subject)
      @subject = subject
      self
    end

    private

    def method_missing(method, *args)
      @method, @args = method, args
      constrain_method_invocation
      invoke_method
      constrain_return_value
      @return_value
    end

    def constrain_method_invocation
      @contracts.include?(@method) or raise MethodViolation
    end

    def invoke_method
      @return_value = @subject.public_send(@method, *@args)
    end

    def constrain_return_value
      @contracts[@method].valid_return_value?(@return_value) or raise ReturnViolation
    end

  end

end
