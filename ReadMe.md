stp-validate-cf-manifest
========================

A CF manifest.yml Validator

This is a hack while the stp command is being developed. At some point in the
future you will be able to run a command like this:

```
stp validate -s manifest.stp foo/manifest.yml bar/manifest.yml
```

For now, use the Docker based instructions below:

----

You can validate one or more CF `manifest.yml` files with this command:

```
docker run -iv $PWD:/data ingy/stp-validate-cf-manifest /stp/stp-validate-cf-manifest <manifest-yml-file>...
```

For example, from this directory, run:

```
docker run -iv $PWD:/data ingy/stp-validate-cf-manifest /stp/stp-validate-cf-manifest manifest.yml
```

For ease of use, make a local shell alias:

```
alias svcm='docker run -iv $PWD:/data ingy/stp-validate-cf-manifest /stp/stp-validate-cf-manifest'
```

Then:

```
svcm <manifest-yml-file>...
```
