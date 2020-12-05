ARG BASE_IMAGE=pureengage-docker-dev.jfrog.io/base/centos7-node10:latest
FROM node:10 as stage1
WORKDIR /opt/genesys/katana/resiliency/
COPY package*.json ./
COPY . .
RUN apt update
RUN apt-get install -y git && apt-get install -y openssh-client
ARG SSH_PRIVATE_KEY
ARG SSH_PUBLIC_KEY
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan git.scm.genesys.com >> /root/.ssh/known_hosts
RUN ["npm", "install"]
FROM ${BASE_IMAGE} as stage2
ARG BASE_IMAGE=node:10
ARG BUILD_TIME
ARG BUILD_URL
ARG GIT_COMMIT
ARG BUILD_TAG
LABEL com.genesys.pureengage.inboundservice.resiliency.image-name="inboundservice/resiliency" \
      com.genesys.pureengage.inboundservice.resiliency.bdh-project="PE/inboundservice/resiliency" \
      com.genesys.pureengage.inboundservice.resiliency.build-link="${BUILD_URL}" \
      com.genesys.pureengage.inboundservice.resiliency.build-time-iso8601m="${BUILD_TIME}" \
      com.genesys.pureengage.inboundservice.resiliency.commit-hash="${GIT_COMMIT}" \
      com.genesys.pureengage.inboundservice.resiliency.fips-enabled="false" \
      com.genesys.pureengage.inboundservice.resiliency.image-from="${BASE_IMAGE}" \
      com.genesys.pureengage.inboundservice.resiliency.image-tag="${BUILD_TAG}" \
      com.genesys.pureengage.inboundservice.resiliency.image-version="${BUILD_TAG}" \
      io.k8s.description="Genesys Inbound resiliency Test services" \
      io.k8s.display-name="Genesys Inbound resiliency Test Service"
USER root
WORKDIR /opt/genesys/katana/resiliency/
COPY --from=stage1 /opt/genesys/katana/resiliency/ .
CMD ["npm", "test"]

