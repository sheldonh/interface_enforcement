require 'sender'
require 'test_interface/enforcer'

module TestInterface

  class Proxy

    def initialize(interface, subject)
      @interface = interface
      @subject = subject
      @enforcer = Enforcer.new(interface, subject)
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
        raise ArgumentError, "nonexistent or private method #{method_name} may not form part of an interface"
      end
    end

    def define_delegator_method(method_name)
      instance_eval %Q{
        def #{method_name}(*args)
          @enforcer.enforce(:#{method_name}, args, __sender__)
        end
      }
    end

  end

end