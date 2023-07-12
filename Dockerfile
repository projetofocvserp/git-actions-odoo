# syntax=docker/dockerfile:1
FROM ubuntu:22.04 as ubuntu_base

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV LANG=C.UTF-8
ENV TZ=America/Sao_Paulo
ENV DEBIAN_FRONTEND=noninteractive

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    gnupg2 \
    gsfonts \
    libffi-dev \
    libjpeg-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libxslt-dev \
    libxslt1-dev \
    libzip-dev \
    npm \
    pkg-config \
    postgresql-client \
    python3 \
    python3-babel \
    python3-decorator \
    python3-dev \
    python3-docutils \
    python3-feedparser \
    python3-gevent \
    python3-html2text \
    python3-idna \
    python3-jinja2 \
    python3-libsass \
    python3-lxml \
    python3-mako \
    python3-mock \
    python3-num2words \
    python3-ofxparse \
    python3-openssl \
    python3-passlib \
    python3-pdfminer \
    python3-phonenumbers \
    python3-pip \
    python3-polib \
    python3-psutil \
    python3-psycopg2 \
    python3-pydot \
    python3-pyldap \
    python3-pypdf2 \
    python3-qrcode \
    python3-renderpm \
    python3-reportlab \
    python3-requests \
    python3-serial \
    python3-setuptools \
    python3-slugify \
    python3-stdnum \
    python3-usb \
    python3-venv \
    python3-vobject \
    python3-werkzeug \
    python3-wheel \
    python3-xlrd \
    python3-xlsxwriter \
    python3-xlwt \
    python3-zeep \
    swig \ 
    wget \
    xfonts-75dpi \
    xfonts-base \
    xz-utils \
    zip \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ///////////////////////////////////
# ########## Python Build ##########
# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
FROM ubuntu_base as python_base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="$PATH:/root/.local/bin"
ARG ODOO_REQUIREMENTS=https://raw.githubusercontent.com/odoo/odoo/15.0/requirements.txt

RUN pip3 install --no-cache-dir --user -r ${ODOO_REQUIREMENTS} && pip3 install --user --no-cache-dir flanker \
    && pip3 install --user --no-cache -U pyopenssl

# ///////////////////////////////////
# ########## Odoo Build ##########
# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
FROM python_base as odoo_base

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]
ARG LIB_ODOO_PATH=/var/lib/odoo
ARG USERNAME=odoo
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} $USERNAME \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -s /bin/bash -m ${USERNAME}

ARG WKHTMLTOPDF_FILE=https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
ARG WKHTMLTOPDF_CHECKSUM=800eb1c699d07238fee77bf9df1556964f00ffcf

RUN curl -o wkhtmltox.deb -sSL ${WKHTMLTOPDF_FILE} \
    && echo ${WKHTMLTOPDF_CHECKSUM} wkhtmltox.deb | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
    && mkdir ${LIB_ODOO_PATH} \
    && chown -R ${USERNAME}:${USERNAME} ${LIB_ODOO_PATH} \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# INSTALL ODOO
ARG ODOO_VERSION=15.0
ARG ODOO_RELEASE=latest
ARG ODOO_SHA=ea86be3815a763d091f25e1be6f24ca904feed6d
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    # && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && touch /var/log/odoo/odoo-server.log \
    && ln -sf /dev/stdout /var/log/odoo/odoo-server.log \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/* odoo.deb

RUN npm install -g rtlcss sass less

RUN touch /var/log/odoo/odoo-server.log \ 
    && ln -sf /dev/stdout /var/log/odoo/odoo-server.log

FROM odoo_base

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ARG USERNAME=odoo
ARG ODOO_ADDONS=/mnt/extra-addons
ENV ODOO_RC=/etc/odoo/odoo.conf
ENV PATH="$PATH:/home/odoo/.local/bin"

COPY --chown=${USERNAME}:${USERNAME} ./extra-addons ${ODOO_ADDONS}
COPY --chown=${USERNAME}:${USERNAME} ./config/k8s/odoo.conf ${ODOO_RC}
COPY --chown=${USERNAME}:${USERNAME} --chmod=744 ./config/k8s/entrypoint.sh /
COPY --chown=${USERNAME}:${USERNAME} --chmod=744 ./config/k8s/wait-for-psql.py /usr/local/bin/wait-for-psql.py

RUN pip3 install -r /mnt/extra-addons/requirements.txt

USER odoo

EXPOSE 8069 8072

ENTRYPOINT ["/entrypoint.sh"]

CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
