SHELL += -eu

BLUE		:= \033[0;34m
GREEN		:= \033[0;32m
RED   		:= \033[0;31m
NC    		:= \033[0m
EMPLOYEE	:= `aws sts get-caller-identity --output text --query 'Arn'`
ACCOUNT		:= `aws sts get-caller-identity --output text --query 'Account'`
TAGS		:= Name=${APP} Account=$(ACCOUNT) 'Cost centre'=Operations Project=ODFE Service=Analytics Environment=${STAGE} Role=Logging Employee=$(EMPLOYEE)

build:
	@echo "${GREEN}✓ building cloudformation resources... ${NC}\n"
	aws cloudformation package --template-file master.yml --s3-bucket ${BUCKET} --s3-prefix production/${APP}/${REGION}/${STAGE} --output-template-file master.pack.yml --profile $(profile)
	@echo "${GREEN}✓ builds completed, test template... ${NC}\n"
	aws cloudformation deploy --template-file master.pack.yml --stack-name ${APP}-${STAGE} --capabilities CAPABILITY_NAMED_IAM --no-execute-changeset --region ${REGION} --profile $(profile)

deploy: build
	@echo "${GREEN}✓ Deploying stack ${NC}\n"
	aws cloudformation deploy --template-file master.pack.yml --stack-name ${APP}-${STAGE} --capabilities CAPABILITY_NAMED_IAM --region ${REGION} --profile $(profile) --tags $(TAGS)

describe:
	@echo "${GREEN}✓ Describe the stack ${NC}\n"
	aws cloudformation describe-stacks --stack-name ${APP}-${STAGE} --region ${REGION} --profile $(profile) --output text

protection:
	aws cloudformation update-termination-protection --enable-termination-protection --stack-name ${APP}-${STAGE} --region ${REGION} --profile $(profile)

delete:
	aws cloudformation delete-stack --stack-name ${APP}-${STAGE} --region ${REGION} --profile $(profile)

.DEFAULT_GOAL := help
.PHONY: deploy
