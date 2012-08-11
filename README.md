interface\_enforcer
===================

*WARNING* This software does not represent an opinion. It is not a call to
do things a certain way. It is an exploration of the forces and concerns at
play when doing things a certain way. Think for yourself, and be kind to
the children.

If you're looking for a polished tool to use, consider these fine efforts
instead:

* [Aditya Bhargava's contracts.ruby](http://egonschiele.github.com/contracts.ruby/) - A beautiful DSL for specifying contracts.
* [Josh Cheek's surrogate](Framework to aid in handrolling mock/spy objects.) - A comfortable framework for handrolling mocks and spies.

These projects' interface enforcement strategies are different from the one
embodied in this one, but they are well worth consideration.  Contracts.ruby
provides a fantastic DSL for embedding interface declaration in production
code, and surrogate tackles the much broader scope of mock and spy specification
and use, with weaker interface enforcement than Contracts.ruby or this project.

Also note that one of the dependencies of this gem is currently broken on
ruby-1.9.3, as per [sender issue #4](https://github.com/Asher-/sender/issues/4).
I'm currently working around this by applying [ruby pull #47](https://github.com/ruby/ruby/pull/47)
to my ruby.

Definition
----------

This library provides a construct for applying elective test interface
enforcement in isolated Ruby unit tests:

* _Elective_: The developer chooses which unit interfaces to enforce, and
  must do so with care and effort, in just those cases that seem important to
  her.
* _Test_: The enforcement construct does not participate in the production
  execution path. It is employed as a proxy around units and the test doubles
  that stand in for them, in tests that exercise those units and doubles.
* _Interface_: An interface describes the accessibility, arguments, return
  values and possible exceptions of the methods of a unit and the test doubles
  that stand in for it. The descriptions are arbitrarily expressive, beyond
  classical type safety.
* _Enforcement_: An enforcement construct raises expressive exceptions when
  the unit or test double it is wrapped around behaves in a way that violates
  the interface.

Isolated unit tests are those in which at least one test double is standing
in for a module (class, object, module or service) used by the unit under
test (the test subject).

Demo
----

The file [demo/subscriber\_spec.rb](/sheldonh/interface_enforcer/tree/master/demo/subscriber_spec.rb)
demonstrates the risk present in isolated testing in a loosely typed language,
using a contrived example of an obvious mistake that nobody would make. What is
being demonstrated is the mechanism of elective test interface enforcement, not
the context in which it might be appropriate.

The tests for the Subscriber use a test double for the Publisher. However, the
double does not behave exactly like the Publisher; its gets method returns a
string that is not line-terminated. Therefore, the passing test does not test
the correct use of the Publisher by the Subscriber!

The failing test demonstrates the use of an elective interface to detect a test
double that does not behave like the object it stands in for.

The PublisherInterface would be written by the author of the Publisher, and
would be used by the authors of both the Publisher and the subscriber. It is
defined in terms of the TestInterface::Enforcer for readability, because the
in situ use of TestInterface::Enforcer is more ugly.

Background
----------

This exploration started when I watched two compelling video presentations:

* [Fast Rails Tests -- Corey Haines](http://vimeo.com/30893836)
* [Integration Tests Are a Scam -- J.B. Rainsberger](http://www.infoq.com/presentations/integration-tests-scam/)

J.B. Rainsberger seemed to be arguing that the only way out of integration test
hell (into which I have descended on more than one occasion) was to test units
in isolation from one another, relying on language-native interface enforcement
to mitigate the risk that test doubles fail to prove correct interation with
the units they stand in for.

In Ruby, as in any loosely-typed (or "duck-typed") language, interfaces are
implicit. An object's interface is the set of methods it will respond to at a
given moment, reflecting method definitions applied to it across its life-time
up to that moment.

And so my superficial interpretation of J.B. Rainsberger's hypothesis was that
the only way out of integration test hell was to

* accept the risk that changes to a dependency could break its dependents
  without producing failures in the tests of its dependents, or
* use a strictly typed language with explicit interface support!

I can imagine situations in which one or the other of these responses would be
entirely appropriate. However, the team composition and software rigidity of
my current situation demand further exploration at the very least.

This is why my colleague Ernst van Graan and I began to explore the notion of
elective test interface enforcement in isolated Ruby unit tests.

We are not condemning the practice of integration testing. As an aside, neither
was J.B. Rainsberger; not exactly. We are not promoting any particular style of
testing. We are simply exploring a mechanism for dealing with the fear inherent
a particular style of testing, when the language in play is Ruby.

