# SHARED
build:
	docker build --target BUILDER -t babashka-lambda-archiver .
	docker rm build || true
	docker create --name build babashka-lambda-archiver
	docker cp build:/var/task/function.zip function.zip

# ALTERNATIVE 1: Using CloudFormation
stack = babashka-lambda
s3-bucket = my-bucket

package: build
	aws cloudformation package \
        --template-file stack.yml \
        --s3-bucket $(s3-bucket) \
        --s3-prefix babashka \
        --output-template-file /tmp/stack.yml

deploy: package
	aws cloudformation deploy \
        --template-file /tmp/stack.yml \
        --stack-name $(stack) \
        --capabilities CAPABILITY_IAM \
        --no-fail-on-empty-changeset

get-function-name:
	@aws lambda list-functions | bb -i  "(->> (json/decode (str/join *input*) true) :Functions (filter (fn [function] (re-matches #\".*babashka.*\" (:FunctionName function)))) (map :FunctionName))"

invoke-function:
	@aws lambda invoke --function-name $(function-name) --payload '{}' /dev/stdout

# ALTERNATIVE 2: Using AWS SAM CLI
# we need build-<function name from template.yml> for `sam build` and we need it to output into the SAM-provided artifacts dir:
build-BabashkaLambda: build
	unzip function.zip -d $(ARTIFACTS_DIR)
