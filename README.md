Hebe: JBoss SET Continous Integration Scripts
====

Set of custom scripts to install on SET CI server. Those scripts are supposed to be living on the CI
instance of the team (as per the day of writing this: thunder).

How to build ?
----

As the JBoss SET team is composed of Java developers, the RPM creation is done by a Maven build
rather than by simple set of shell scripts:

    $ maven clean install

Release
---

* update the version
* tag the repository
* run the build
* copy and install the RPM !

Note:
[Hebe](https://en.wikipedia.org/wiki/Hebe) is one of the infant of Zeus - which is the named of the
Ansible configuration in charge of Thunder.
