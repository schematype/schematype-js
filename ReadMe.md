This repo branch contains 927 public CloudFoundry `manifest.yml` files.

See [[manifest.bash]] for how all the files were discovered and downloaded.

All of the files were validated using:

```
docker run -iv $PWD:/data ingy/stp-validate-cf-manifest /stp/stp-validate-cf-manifest <file>
```

At this point 352 are reporting as valid. ALl the errors ore in [[log]]. Each
error could either be an actual data problem, or a problem with the validator.

The validator is pretty fast. Takes 0.4s to validate all 927 files.
