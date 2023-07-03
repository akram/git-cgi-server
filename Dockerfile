FROM openshift/origin-release:golang-1.12 AS go-init-builder
WORKDIR  /go/src/github.com/pasela/git-cgi-server
COPY . .
RUN go get github.com/pasela/git-cgi-server
RUN go build .
RUN openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/C=PE/ST=Lima/L=Lima/O=Acme Inc. /OU=IT Department/CN=acme.com"
RUN cp server.* /usr/bin
RUN cp git-cgi-server /usr/bin
RUN ls -la && pwd
RUN mkdir -p repos/my-repo && cd repos/my-repo && git init .

FROM scratch
COPY --from=go-init-builder /usr/bin/git-cgi-server /git-cgi-server
COPY --from=go-init-builder /usr/bin/server.* /
COPY --from=go-init-builder /go/src/github.com/pasela/git-cgi-server/repos /
ENTRYPOINT ["/git-cgi-server", "--cert-file=/server.crt", "--key-file=/server.key", "/repos"]

