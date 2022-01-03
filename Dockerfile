MAINTAINER Muyinliu Xing <muyinliu@gmail.com>
#------------------------------------------------------------
# stage0: build
FROM alpine:3.12.3 as build_env

# install dependencies
RUN apk add --update python3 python3-dev py3-pip gcc make musl-dev libxml2-dev libxslt-dev git

# prepare
RUN mkdir -p /usr/local/src

# build and install beancount
WORKDIR /usr/local/src
RUN git clone --depth=1 -b support-zh-cn-account-name https://github.com/muyinliu/beancount
WORKDIR /usr/local/src/beancount
RUN python3 -m venv /app
RUN . /app/bin/activate
RUN CFLAGS=-s pip3 install -U /usr/local/src/beancount

# build and install fava
RUN apk add --update nodejs-current npm
WORKDIR /usr/local/src
RUN git clone --depth=1 https://github.com/beancount/fava
WORKDIR /usr/local/src/fava
RUN make
RUN pip3 install babel
RUN pybabel compile -d src/fava/translations # force to compile *.po to *mo
RUN pip3 install -U /usr/local/src/fava

# cleanup
RUN apk del python3-dev gcc make musl-dev libxml2-dev libxslt-dev git nodejs-current npm
RUN pip3 uninstall -y google-api-python-client
RUN find /app -name __pycache__ -exec rm -rf -v {} +
WORKDIR /
RUN rm -rf /usr/local/src
RUN rm -rf /root/.npm
RUN rm -rf /root/.cache/*

#------------------------------------------------------------
# stage1: run fava
FROM alpine:3.12.3
COPY --from=build_env / /
EXPOSE 5000

ENV BEANCOUNT_FILE ""
ENV LC_ALL "C.UTF-8"
ENV LANG "C.UTF-8"
ENV FAVA_HOST "0.0.0.0"

ENTRYPOINT ["fava"]
