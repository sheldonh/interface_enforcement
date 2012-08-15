require 'sender'
require 'interface_enforcement/enforcer'

module InterfaceEnforcement

  class Proxy

    # TODO deject
    def self.proxy(interface, subject, enforcer_type = Enforcer)
      new(interface, subject, enforcer_type)
    end

    private

    def initialize(interface, subject, enforcer_type = Enforcer)
      @interface = interface
      @subject = subject
      @enforcer = enforcer_type.new(interface, subject)
    end

    def method_missing(method, *args)
      @enforcer.enforce(method, args, __sender__)
    end

  end

end