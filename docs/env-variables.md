## Environment Variables

| Key | Description | Required | Value |
|------|------|------|------|
| MONITORING | Gather metrics from nginx and php-fpm, please refer to [Logging with Filebeat, Elasticsearch and Kibana](../docs/logging.md) documentation. | ✘ | true/false |
| DOCKER_CRON | Run a cron job inside a docker container, please refer to [Cron (Docker/Kubernetes)](../docs/cron.md) documentation. | ✘ | true/false |