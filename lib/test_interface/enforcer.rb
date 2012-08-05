module TestInterface

  class Enforcer

    def initialize(contract)
      @contracts = {}
      contract.each do |method, constraints|
        add_method_contract(method, constraints)
      end
    end

    def wrap(subject)
      @subject = subject
      self
    end

    private

    def add_method_contract(method, constraints)
      @contracts[method] = MethodContract.new(constraints)
    end

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
      @contracts[@method].constrain_args(@args)
    end

    def invoke_method
      @return_value = @subject.public_send(@method, *@args)
    rescue Exception => e
      constrain_exception(e)
      raise
    end

    def constrain_exception(e)
      @contracts[@method].constrain_exception(e)
    end

    def constrain_return_value
      @contracts[@method].constrain_return_value(@return_value)
    end

  end

end
