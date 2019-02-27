rbac:
  create: true

sslCertPath: /etc/ssl/certs/ca-bundle.crt

cloudProvider: aws
awsRegion: ${region}

autoDiscovery:
  clusterName: ${cluster_name}
  enabled: true

extraEnv:
  http_proxy: ${http_proxy}
  https_proxy: ${http_proxy}
  no_proxy: ${no_proxy}
