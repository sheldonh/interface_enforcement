require 'deject'
require 'sender'
require 'interface_enforcement/aliased_enforcer'

module InterfaceEnforcement

  class Injector

    ALIAS_PREFIX = 'interface_injected_'

    Deject self
    dependency(:enforcer) do |injector|
      injector.instance_exec { AliasedEnforcer.new(@interface, @subject, ALIAS_PREFIX) }
    end

    # TODO this can go when Interface gets dejected
    def self.inject(interface, subject)
      new(interface, subject).inject
    end

    def initialize(interface, subject)
      @interface = interface
      @subject = subject
    end
    private :initialize

    def inject
      inject_self_into_subject
      setup_delegators_on_subject
    end

    private

    def inject_self_into_subject
      @subject.instance_variable_set(:@interface_injector, self)
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
        @interface_injector.enforcer.enforce(method, args, __sender__)
      end
    end

  end

end