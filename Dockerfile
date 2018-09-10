FROM openshift/base-centos7

MAINTAINER Anthony Green <green@redhat.com>

ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building RHEL cloud images" \
      io.k8s.display-name="builder 0.0.1" \
      io.openshift.tags="builder,0.0.1"

RUN yum install epel-release -y \
    && rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo \
    && yum -y install azure-cli jq libguestfs-tools qemu-img openssl curl python2-pip \
    && yum clean all

RUN cd /opt \
    && wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-215.0.0-linux-x86_64.tar.gz \
    && tar xf google-cloud-sdk-*.gz && rm google-cloud-sdk-*.gz \
    && echo "source /opt/google-cloud-sdk/path.bash.inc" > /etc/profile.d/google-cloud-sdk.sh \
    && pip install awscli

RUN wget https://dl.minio.io/client/mc/release/linux-amd64/mc \
    && chmod +x mc && mv mc /usr/bin

COPY ./tools/ /opt/app-root/

COPY ./s2i/bin/ /usr/libexec/s2i

RUN chown -R 1001:1001 /opt/app-root

USER 1001

CMD ["/usr/libexec/s2i/usage"]
