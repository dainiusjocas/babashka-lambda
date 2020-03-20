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
