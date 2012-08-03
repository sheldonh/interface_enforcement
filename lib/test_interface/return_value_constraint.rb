require 'test_interface/constraint'

module TestInterface

  class Enforcer

    class MethodContract

      module ReturnValueConstraint

        def self.build(specification)
          if specification.is_a?(Proc)
            TestInterface::Constraint::Rule.new(TestInterface::ReturnViolation, specification)
          else
            TestInterface::Constraint::Type.new(TestInterface::ReturnViolation, specification)
          end
        end

      end

    end

  end

end
