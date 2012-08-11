require 'test_interface/violation'

module TestInterface

  class Enforcer

    def initialize(interface, subject, method_invocation_prefix = nil)
      @interface = interface
      @subject = subject
      @method_invocation_prefix = method_invocation_prefix
    end

    def enforce(method, args, sender)
      @method, @args, @sender = method, args, sender
      constrain_protected_access
      constrain_args
      invoke_method.tap { constrain_return_value }
    end

    private

    def constrain_protected_access
      if protected_method?
        subject_is_ancestor_of_sender? or raise NoMethodError, "undefined method `#{@method}' for #{@subject}"
      end
    end

    def protected_method?
      @subject.protected_methods.include?(@method)
    end

    def subject_is_ancestor_of_sender?
      sender_ancestors = @sender.class.ancestors - @sender.class.included_modules
      sender_ancestors.include? @subject.class
    end

    def constrain_args
      method_contract.constrain_args(@args) or raise ArgumentViolation
    end

    def invoke_method
      @return_value = @subject.send(method_to_invoke, *@args)
    rescue Exception => e
      constrain_exception(e)
      raise
    end

    def method_to_invoke
      :"#{@method_invocation_prefix}#{@method}"
    end

    def constrain_exception(e)
      method_contract.constrain_exception(e) or raise ExceptionViolation
    end

    def constrain_return_value
      method_contract.constrain_return_value(@return_value) or raise ReturnViolation
    end

    def method_contract
      @interface.method_contract(@method) or raise MethodViolation
    end

  end

end