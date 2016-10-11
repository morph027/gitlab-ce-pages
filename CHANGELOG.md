# Changelog

**1.2.2**
- add tini (https://github.com/krallin/tini) init system
- deployeritself kicks of helper script
- get rid of zombies caused by nodemon

**1.2.1**
- solve child process’ stdout buffer overflow problem #8

**1.2.0**
- prevent non-GitLab request from destroying project pages and GCP service #5

**1.1.0**
- add CNAME (customized domain) support

**1.0.3**
- add docker build test, unit tests and system tests, enable travis ci
- fix a wrong private token caused crash bug

**1.0.2**
- fix a bug when GitLab user has a customized name
- remove artifact after decompressing

**1.0.1**
- make document clearer

**1.0.0**
- basically works
