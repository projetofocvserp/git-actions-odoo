FROM registry.access.redhat.com/ubi8/ubi:latest as rhel_base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG=C.UTF-8
ENV TZ=America/Sao_Paulo
ENV LANG=C.UTF-8
ENV TZ=America/Sao_Paulo

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    yum update -y && \
    yum install -y \
    gcc openssl-devel bzip2-devel libffi-devel wget make

WORKDIR /usr/src

RUN wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz && \
    tar xzf Python-3.10.0.tgz

WORKDIR /usr/src/Python-3.10.0

RUN ./configure --enable-optimizations && \
    make altinstall

RUN ln -sf /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -sf /usr/local/bin/pip3.10 /usr/bin/pip3
