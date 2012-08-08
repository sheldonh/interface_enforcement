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
        instance_eval delegator_definition(method_name)
      end
    end

    def delegator_definition(method_name)
      %Q{
          def #{method_name}(*args)
            @method, @args = :#{method_name}, args
            constrain_args
            invoke_method.tap { constrain_return_value }
          end
        }
    end

    def constrain_args
      method_contract.constrain_args(@args)
    end

    def invoke_method
      @return_value = @subject.public_send(@method, *@args)
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