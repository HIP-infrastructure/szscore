ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION
ARG TAG

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

# It copies the installation script over,
# and does the apt-get install/cleanup dance around it.
COPY ./apps/${APP_NAME}/${APP_VERSION}.sh .

# The szcore-evaluation package pin Python 3.12, when it's all 3.10 here.
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-numpy \
        git && \
    pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir --ignore-requires-python \
        "git+https://github.com/danjjl/szcore-evaluation@master#egg=szcore-evaluation" && \
    \
    ./${APP_VERSION}.sh && \
    \
    apt-get remove -y --purge \
        git && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="terminal"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
