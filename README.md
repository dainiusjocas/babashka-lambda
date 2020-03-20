# babashka-lambda

Babashka script packaged as AWS Lambda.

This example requires GNU Make, Docker, and AWS CLI, babashka, clojure.

## Usage

```shell script
make stack="babashka-lambda" s3-bucket="my-bucket" deploy
```

Make sure that you have `my-bucket`.

## Development

Open `src/lambda/core.clj` and implement your `handler-fn`.

`handler-fn` is a function that takes in clojure map that is parsed from the request body.

## Details

```shell script
make build
```
Will create `function.zip` archive that is ready to be deployed as AWS Lambda into a custom runtime.

The contents of `function.zip` are:
```text
$ ls -a
  .  ..  bb  bootstrap  cp  deps.edn  .gitlibs  .m2  resources  src
```
Where:
- `bb`: babashka binary
- `bootstrap`: AWS Lambda entry point script
- `cp`: generated classpath text file
- `deps.edn`
- `.gitlibs`: directory with gitlibs
- `.m2`: directory with Maven dependencies
- `resources`:
- `src`: directory with babashka scripts

