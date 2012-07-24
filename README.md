interface\_enforcer
===================

This repository proves the concept and value of elective test interfaces for
Ruby.

The file demo/subscriber\_spec.rb demonstrates the risk present in isolated
testing in a loosely typed language.

The tests for the Subscriber use a test double for the Publisher. However, the
double does not behave exactly like the Publisher; its gets method returns a
string that is not line-terminated. Therefore, the passing test does not test
the correct use of the Publisher by the Subscriber!

The failing test demonstrates the use of an elective interface to detect a test
double that does not behave like the object it stands in for.

The PublisherInterface would be written by the author of the Publisher, and
would be used by the authors of both the Publisher and the subscriber. It is
defined in terms of the InterfaceEnforcer.

The InterfaceEnforcer is a class I plan to flesh out and make available as a
library. This repository is the start of that library, which I hope culminates
in a gem.
