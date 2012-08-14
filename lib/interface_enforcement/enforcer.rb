require 'interface_enforcement/access_control'
require 'interface_enforcement/violation'

module InterfaceEnforcement

  class Enforcer

    def initialize(interface, subject)
      @interface = interface
      @subject = subject
    end

    def enforce(method, args, sender)
      @method, @args, @sender = method, args, sender
      constrain_access
      constrain_args
      invoke_method.tap { constrain_return_value }
    end

    private

    def constrain_access
      control = AccessControl.new(@subject, method_to_invoke)
      control.allows?(@sender, @method) or raise NoMethodError, "undefined method `#{@method}' for #{@subject}"
    end

    def constrain_args
      method_contract.allows_args?(@args) or raise ArgumentViolation
    end

    def invoke_method
      @return_value = @subject.send(method_to_invoke, *@args)
    rescue Exception => e
      constrain_exception(e)
      raise
    end

    def method_to_invoke
      @method
    end

    def constrain_exception(e)
      method_contract.allows_exception?(e) or raise ExceptionViolation
    end

    def constrain_return_value
      method_contract.allows_return_value?(@return_value) or raise ReturnViolation
    end

    def method_contract
      @interface.method_contract(@method) or raise MethodViolation
    end

  end

end