#!/bin/bash
gcloud container clusters create word-forward \
--image-type=COS \
--num-nodes=2 \
--preemptible \
--machine-type=n1-standard-1

cat <<EOF > nginx.yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - nginx
              topologyKey: kubernetes.io/hostname
EOF

kubectl create -f nginx.yaml
rm nginx.yaml
kubectl describe pods > result.txt
gcloud container clusters delete word-forward