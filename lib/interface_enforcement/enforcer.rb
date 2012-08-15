require 'interface_enforcement/access_control'
require 'interface_enforcement/violation'

module InterfaceEnforcement

  class Enforcer

    def initialize(interface, subject, access_control = AccessControl)
      @interface = interface
      @subject = subject
      @access_control = access_control
    end

    def enforce(method, args, sender)
      @method, @args, @sender = method, args, sender
      constrain_preconditions
      constrain_invocation
      @return_value
    end

    private

    def constrain_preconditions
      method_must_be_accessible
      method_contract_must_exist
    end

    def method_must_be_accessible
      unless @access_control.subject_allows_sender?(@subject, @sender, method_to_invoke)
        raise NoMethodError, "undefined method `#{@method}' for #{@subject}"
      end
    end

    def method_contract_must_exist
      @interface.method_contracted?(@method) or raise MethodViolation
    end

    def constrain_invocation
      constrain_args
      invoke_method
      constrain_return_value
    rescue Exception => e
      constrain_exception(e)
      raise
    end

    def constrain_args
      @interface.allows_args?(@method, @args) or raise ArgumentViolation
    end

    def invoke_method
      @return_value = @subject.send(method_to_invoke, *@args)
    end

    def method_to_invoke
      @method
    end

    def constrain_return_value
      @interface.allows_return_value?(@method, @return_value) or raise ReturnViolation
    end

    def constrain_exception(e)
      @interface.allows_exception?(@method, e) or raise ExceptionViolation
    end

  end

end