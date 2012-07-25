require 'test_interface/method_contract'

module TestInterface

  class Enforcer

    def initialize(contract)
      @contracts = {}
      contract.each do |method, constraints|
        @contracts[method] = MethodContract.new(constraints)
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
      constrain_args
      invoke_method.tap { constrain_return_value }
    end

    def constrain_method_invocation
      @contracts.include?(@method) or raise MethodViolation
    end

    def constrain_args
      @contracts[@method].valid_args?(@args) or raise ArgumentViolation
    end

    def invoke_method
      @return_value = @subject.public_send(@method, *@args)
    end

    def constrain_return_value
      @contracts[@method].valid_return_value?(@return_value) or raise ReturnViolation
    end

  end

end
