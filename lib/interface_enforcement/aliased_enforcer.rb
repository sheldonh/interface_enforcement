require 'interface_enforcement/enforcer'
require 'interface_enforcement/violation'

module InterfaceEnforcement

  class AliasedEnforcer < Enforcer

    def initialize(interface, subject, alias_prefix = nil)
      super(interface, subject)
      @alias_prefix = alias_prefix
    end

    private

    def method_to_invoke
      :"#{@alias_prefix}#{@method}"
    end

  end

end