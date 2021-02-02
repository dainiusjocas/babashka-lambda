# babashka-lambda

Babashka script packaged as AWS Lambda.

This example requires GNU Make, Docker, and AWS CLI, babashka, clojure.

## Usage

### With AWS SAM CLI

Build: `sam build`

Deploy: `sam deploy --guided` (and just `sam deploy` thereafter)

Test locally: `sam local invoke --event events/event-cloudwatch-event.json --debug`

### With CloudFormation

Provide `stack` for cloudformation stack name and `s3-bucket` params.

```shell script
make stack="babashka-lambda" s3-bucket="my-bucket" deploy
```

Make sure that your provided S3 bucket, e.g. `my-bucket` exists. And of course, make sure you are authorized to deploy to AWS.

## Test Lambda with AWS CLI

```shell script
make function-name=$(make get-function-name) invoke-function
```
The response should be similar:
```shell script
{"test":"test914"}{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```

Get the function name:

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

