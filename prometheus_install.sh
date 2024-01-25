#!/bin/bash

sudo apt install prometheus prometheus-alertmanager

sudo cp /opt/prometheus.yml /opt/alertmanager.yml /etc/prometheus/

sudo systemctl daemon-reload
sudo systemctl restart prometheus
