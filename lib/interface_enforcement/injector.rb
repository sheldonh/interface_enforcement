require 'sender'
require 'interface_enforcement/aliased_enforcer'

module InterfaceEnforcement

  class Injector

    ALIAS_PREFIX = 'interface_injected_'

    # TODO deject
    def self.inject(interface, subject, enforcer_type = AliasedEnforcer)
      new(interface, enforcer_type).inject(subject)
    end

    def initialize(interface, enforcer_type)
      @interface = interface
      @enforcer_type = enforcer_type
    end
    private :initialize

    def inject(subject)
      @subject = subject
      inject_enforcer_into_subject
      setup_delegators_on_subject
    end

    private

    def inject_enforcer_into_subject
      enforcer = @enforcer_type.new(@interface, @subject, ALIAS_PREFIX)
      @subject.instance_variable_set(:@interface_enforcer, enforcer)
    end

    def setup_delegators_on_subject
      subject_methods.each do |method|
        alias_subject_method(method)
        redefine_subject_method(method)
      end
    end

    def subject_methods
      #noinspection RubyResolve
      (@subject.methods - @subject.private_methods) - Object.instance_methods
    end

    def alias_subject_method(method)
      aliased_method = :"#{ALIAS_PREFIX}#{method}"
      @subject.singleton_class.send :alias_method, aliased_method, method
    end

    def redefine_subject_method(method)
      @subject.define_singleton_method method do |*args|
        #noinspection RubyResolve
        @interface_enforcer.enforce(method, args, __sender__)
      end
    end

  end

end