FROM ubuntu:20.04

WORKDIR /mnt

RUN apt --yes update && apt --yes install cloud-image-utils

ENTRYPOINT ["cloud-localds"]
