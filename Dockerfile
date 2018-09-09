FROM openshift/base-centos7

MAINTAINER Anthony Green <green@redhat.com>

ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building RHEL cloud images" \
      io.k8s.display-name="builder 0.0.1" \
      io.openshift.tags="builder,0.0.1"

RUN yum install epel-release -y \
    && yum -y install jq libguestfs-tools qemu-img \
    && yum clean all

RUN wget https://dl.minio.io/client/mc/release/linux-amd64/mc \
    && chmod +x mc

COPY ./tools/ /opt/app-root/

COPY ./s2i/bin/ /usr/libexec/s2i

RUN chown -R 1001:1001 /opt/app-root

USER 1001

CMD ["/usr/libexec/s2i/usage"]
