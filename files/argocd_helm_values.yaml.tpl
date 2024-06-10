fullnameOverride: ${name}

configs:
  params:
    server.insecure: true

server:
  ingress:
    enabled: ${ingress_enabled}
    ingressClassName: alb
    hostname: ${ingress_host}
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/group.name: ${ingress_group_name}
      alb.ingress.kubernetes.io/load-balancer-name: ${ingress_name}
      alb.ingress.kubernetes.io/subnets: ${ingress_subnet_ids}
      alb.ingress.kubernetes.io/scheme: ${ingress_scheme}
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'

%{ if ha }
redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  autoscaling:
    enabled: true
    minReplicas: 2

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicas: 2
%{ endif }