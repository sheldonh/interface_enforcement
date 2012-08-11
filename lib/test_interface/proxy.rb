require 'sender'

module TestInterface

  class Proxy

    def initialize(interface, subject)
      @interface = interface
      @subject = subject
      setup_delegators
    end

    private

    def setup_delegators
      @interface.each_method_name do |method_name|
        ensure_method_responds(method_name)
        define_delegator_method(method_name)
      end
    end

    def ensure_method_responds(method_name)
      if !@subject.respond_to?(method_name)
        raise ArgumentError, "nonexistent method #{method_name} may not form part of an interface"
      end
    end

    def define_delegator_method(method_name)
      instance_eval %Q{
        def #{method_name}(*args)
          @method, @args, @sender = :#{method_name}, args, __sender__
          constrain_protected_access
          constrain_args
          invoke_method.tap { constrain_return_value }
        end
      }
    end

    # TODO I don't like Proxy raising Violation exceptions; that's been MethodContract's job
    def constrain_protected_access
      if protected_method?
        raise TestInterface::PrivacyViolation unless subject_is_ancestor_of_sender?
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
      method_contract.constrain_args(@args)
    end

    def invoke_method
      @return_value = @subject.send(@method, *@args)
    rescue Exception => e
      constrain_exception(e)
      raise
    end

    def constrain_exception(e)
      method_contract.constrain_exception(e)
    end

    def constrain_return_value
      method_contract.constrain_return_value(@return_value)
    end

    def method_contract
      @interface.method_contract(@method)
    end

  end

end