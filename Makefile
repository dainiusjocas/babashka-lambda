stack = babashka-lambda
s3-bucket = my-bucket

build:
	docker build --target BUILDER -t babashka-lambda-archiver .
	docker rm build || true
	docker create --name build babashka-lambda-archiver
	docker cp build:/var/task/function.zip function.zip

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
	@aws lambda list-functions | bb -i  "(require '[cheshire.core :as json]) (->> (json/decode (str/join *input*) true) :Functions (filter (fn [function] (re-matches #\".*babashka.*\" (:FunctionName function)))) (map :FunctionName))"

invoke-function:
	@aws lambda invoke --function-name $(function-name) --payload '{}' /dev/stdout
