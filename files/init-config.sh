#!/bin/sh
  sed -i -ec "s/GRAFANA_SECRET/$GRAFANA_SECRET/" /etc/config/prometheus.yml
  sed -i -ec "s/GRAFANA_USERNAME/$GRAFANA_USERNAME/" /etc/config/prometheus.yml
  sed -i -ec "s/GRAFANA_PASSWORD/$GRAFANA_PASSWORD/" /etc/config/prometheus.yml