#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_WEAVE_TEMPLATE=${LOCAL_MANIFESTS_DIR}/kube-cni-weave.yaml
mkdir -p $(dirname $KUBE_WEAVE_TEMPLATE)
cat << EOF > $KUBE_WEAVE_TEMPLATE
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: weave-net
  namespace: kube-system
spec:
  template:
    metadata:
      labels:
        name: weave-net
      annotations:
        scheduler.alpha.kubernetes.io/tolerations: |
          [
            {
              "key": "dedicated",
              "operator": "Equal",
              "value": "master",
              "effect": "NoSchedule"
            }
          ]
    spec:
      hostNetwork: true
      hostPID: true
      containers:
        - name: weave
          image: weaveworks/weave-kube:1.9.2
          command:
            - /home/weave/launch.sh
          livenessProbe:
            initialDelaySeconds: 30
            httpGet:
              host: 127.0.0.1
              path: /status
              port: 6784
          securityContext:
            privileged: true
          volumeMounts:
            - name: weavedb
              mountPath: /weavedb
            - name: cni-bin
              mountPath: /host/opt
            - name: cni-bin2
              mountPath: /host/home
            - name: cni-conf
              mountPath: /host/etc
            - name: dbus
              mountPath: /host/var/lib/dbus
            - name: lib-modules
              mountPath: /lib/modules
          resources:
            requests:
              cpu: 10m
        - name: weave-npc
          image: weaveworks/weave-npc:1.9.2
          resources:
            requests:
              cpu: 10m
          securityContext:
            privileged: true
      restartPolicy: Always
      volumes:
        - name: weavedb
          emptyDir: {}
        - name: cni-bin
          hostPath:
            path: /opt
        - name: cni-bin2
          hostPath:
            path: /home
        - name: cni-conf
          hostPath:
            path: /etc
        - name: dbus
          hostPath:
            path: /var/lib/dbus
        - name: lib-modules
          hostPath:
            path: /lib/modules

EOF
