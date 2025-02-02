FROM openshift/origin-release:golang-1.12 AS go-init-builder
WORKDIR  /go/src/github.com/pasela/git-cgi-server
COPY . .
RUN go get github.com/pasela/git-cgi-server
RUN go build .
RUN openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/C=PE/ST=Lima/L=Lima/O=Acme Inc. /OU=IT Department/CN=acme.com"
RUN mkdir -p repos/my-repo && cd repos/my-repo && git init .

FROM registry.access.redhat.com/ubi8/ubi
COPY --from=go-init-builder /go/src/github.com/pasela/git-cgi-server/git-cgi-server /usr/bin
COPY --from=go-init-builder /go/src/github.com/pasela/git-cgi-server/server.key /server.key
COPY --from=go-init-builder /go/src/github.com/pasela/git-cgi-server/server.crt /server.crt
COPY --from=go-init-builder /go/src/github.com/pasela/git-cgi-server/repos /tmp/repos/
RUN yum --nodocs install -y --setopt=install_weak_deps=False git 
RUN chmod -R a+rw /tmp/repos
ENTRYPOINT ["/usr/bin/git-cgi-server", "--cert-file=/server.crt", "--key-file=/server.key", "--export-all", "/tmp/repos"]


