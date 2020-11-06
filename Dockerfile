FROM neilpang/acme.sh
RUN apk update && apk add bash python
ENV CLOUDSDK_CORE_DISABLE_PROMPTS=1 CLOUDSDK_ROOT_DIR=/usr/local/bin
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -s /root/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud

## Complicated way to run: source /root/google-cloud-sdk/path.bash.inc
## Works only for login shell, required: docker exec -it container_name sh --login
# RUN echo "cd /root/google-cloud-sdk && source /root/google-cloud-sdk/path.bash.inc" > /etc/profile.d/gcloud_path.sh && chmod +x /etc/profile.d/gcloud_path.sh
