# Create a Standard mode cluster

It may take around 7 minutes.

```bash
CLUSTER_NAME="sample-cluster-standard-dev"

gcloud container clusters create ${CLUSTER_NAME} \
       --zone us-central1-a --additional-zones us-central1-b,us-central1-c \
       --num-nodes=1 --min-nodes=1 --max-nodes=10 \
       --enable-autoscaling --autoscaling-profile optimize-utilization 
```

```bash
NAME                        LOCATION       MASTER_VERSION  MASTER_IP       MACHINE_TYPE  NODE_VERSION    NUM_NODES  STATUS
ample-cluster-standard-dev  us-central1-a  1.24.5-gke.600  xx.xxx.xxx.xxx  e2-medium     1.24.5-gke.600  3          RUNNING
```

**IMPORTANT**:
In case of the Standard mode cluster, you **HAVE to enable the workload Identity** on [GCP console](https://console.cloud.google.com/kubernetes/list/overview) and update node pools:

![enable-workload-identity](./screenshots/enable-workload-identity.png?raw=true)

```bash
gcloud container node-pools update default-pool \
    --cluster=${CLUSTER_NAME} \
    --workload-metadata=GKE_METADATA
```

```bash
Default change: During creation of nodepools or autoscaling configuration changes for cluster versions greater than 1.24.1-gke.800 a default location policy is applied. For Spot and PVM it defaults to ANY, and for all other VM kinds a BALANCED policy is used. To change the default values use the `--location-policy` flag.
Updating node pool default-pool... Updating default-pool, done with 1 out of 3 nodes (33.3%): 1 being processed...
Updating node pool default-pool... Updating default-pool, done with 2 out of 3 nodes (66.7%): 1 being processed...  
Updating node pool default-pool... Updating default-pool, done with 3 out of 3 nodes (100.0%): 1 succeeded...done.                                                                                      
Updated [https://container.googleapis.com/v1/projects/moloco-sre/zones/us-central1-a/clusters/sample-cluster-test-dev/nodePools/default-pool].
gcloud container node-pools update default-pool    3.64s user 0.66s system 0% cpu 12:37.33 total
```

```bash
gcloud container clusters get-credentials ${CLUSTER_NAME} --region=${COMPUTE_ZONE} --project ${PROJECT_ID}
```
