require 'sender'
require 'test_interface/aliased_enforcer'

module TestInterface

  class Injector

    ALIAS_PREFIX = 'interface_injected_'

    def initialize(interface)
      @interface = interface
    end

    def inject(subject)
      @subject = subject
      inject_enforcer_into_subject
      setup_delegators_on_subject
      @subject
    end

    private

    def inject_enforcer_into_subject
      enforcer = AliasedEnforcer.new(@interface, @subject, ALIAS_PREFIX)
      @subject.instance_variable_set(:@interface_enforcer, enforcer)
    end

    def setup_delegators_on_subject
      subject_methods.each do |method|
        alias_subject_method(method)
        redefine_subject_method(method)
      end
    end

    def subject_methods
      (@subject.methods - @subject.private_methods) - Object.instance_methods
    end

    def alias_subject_method(method)
      aliased_method = :"#{ALIAS_PREFIX}#{method}"
      @subject.singleton_class.send :alias_method, aliased_method, method
    end

    def redefine_subject_method(method)
      @subject.define_singleton_method method do |*args|
        @interface_enforcer.enforce(method, args, __sender__)
      end
    end

  end

end