module InterfaceEnforcement

  shared_examples_for 'an interface enforcer' do

    let(:interface) { double(Interface).as_null_object }
    let(:subject) { Subject.new }
    let(:access_control) { double(AccessControl).as_null_object }
    let(:enforcer) { Enforcer.new(interface, subject, access_control) }

    describe 'preconditions' do

      it 'gives the configured access control the sender, subject and method to invoke' do
        access_control.should_receive(:subject_allows_sender?).with(subject, self, :get).and_return true
        enforcer.enforce(:get, [], self)
      end

      it 'raises NoMethodError when access is denied' do
        access_control.stub(:subject_allows_sender?).and_return false
        expect { enforcer.enforce(:get, [], self) }.to raise_error NoMethodError
      end

      it 'raises MethodViolation when the interface has no contract for the method' do
        interface.should_receive(:method_contracted?).with(:get).and_return nil
        expect { enforcer.enforce(:get, [], self) }.to raise_error MethodViolation
      end

    end

    describe 'invocation' do

      it 'raises ArgumentViolation if the interface disallows the args' do
        interface.should_receive(:allows_args?).with(:get, []).and_return false
        expect { enforcer.enforce(:get, [], self) }.to raise_error ArgumentViolation
      end

      it 'raises ReturnViolation if the interface disallows the return value' do
        subject.set "new knowledge"
        interface.should_receive(:allows_return_value?).with(:get, "new knowledge").and_return false
        expect { enforcer.enforce(:get, [], self) }.to raise_error ReturnViolation
      end

      it 'raises ExceptionViolation if the interface disallows a raised exception' do
        subject.should_receive(:get).and_raise e = RuntimeError.new
        interface.should_receive(:allows_exception?).with(:get, e).and_return false
        expect { enforcer.enforce(:get, [], self) }.to raise_error ExceptionViolation
      end

      it 'delegates to the method on the subject' do
        subject.set "new knowledge"
        enforcer.enforce(:get, [], self).should == "new knowledge"
      end

    end

  end

end
