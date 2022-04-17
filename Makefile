forcetest:
	go clean -testcache
	HISHTORY_TEST=1 go test -p 1 ./...

test:
	HISHTORY_TEST=1 go test -p 1 ./...

acttest:
	act push -j test

release:
	expr `cat VERSION` + 1 > VERSION
	git add VERSION
	git commit -m "Bump hishtory version to `cat VERSION`"
	git tag v0.`cat VERSION`
	git push
	git push --tags

build-static:
	docker build -t gcr.io/dworken-k8s/hishtory-static -f backend/web/caddy/Dockerfile .

build-api:
	docker build -t gcr.io/dworken-k8s/hishtory-api -f backend/server/Dockerfile . 

deploy-static: build-static
	docker push gcr.io/dworken-k8s/hishtory-static
	kubectl patch deployment hishtory-static -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"ts\":\"`date|sed -e 's/ /_/g'|sed -e 's/:/-/g'`\"}}}}}}"

deploy-api: build-api
	docker push gcr.io/dworken-k8s/hishtory-api
	kubectl patch deployment hishtory-api -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"ts\":\"`date|sed -e 's/ /_/g'|sed -e 's/:/-/g'`\"}}}}}}"

deploy: release deploy-static deploy-api

