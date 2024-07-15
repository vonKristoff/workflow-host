# Based on https://github.com/denoland/deno_docker/blob/main/alpine.dockerfile

ARG DENO_VERSION=1.14.0
ARG BIN_IMAGE=denoland/deno:bin-${DENO_VERSION}
FROM ${BIN_IMAGE} AS bin

FROM frolvlad/alpine-glibc:alpine-3.13

RUN apk --no-cache add ca-certificates
RUN apk add git

RUN addgroup --gid 1000 deno \
    && adduser --uid 1000 --disabled-password deno --ingroup deno \
    && mkdir /deno-dir/ \
    && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG DENO_VERSION
ENV DENO_VERSION=${DENO_VERSION}
COPY --from=bin /deno /bin/deno

WORKDIR /data
RUN git clone https://github.com/vonKristoff/static-docs.git

WORKDIR /deno-dir
COPY /data/vault .
COPY . .


ENTRYPOINT ["/bin/deno"]
CMD ["run", "--allow-net", "https://deno.land/std/examples/echo_server.ts"]
