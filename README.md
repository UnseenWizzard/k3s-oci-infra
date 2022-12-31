# A k3s Kubernetes setup on Oracle Cloud 

A toy setup of a k3s cluster on Oracle Cloud Free Tier.

Roughly based on 
* https://github.com/r0b2g1t/k3s-cluster-on-oracle-cloud-infrastructure
* https://medium.com/geekculture/how-to-create-an-always-free-k8s-cluster-in-oracle-cloud-60be3b107c44

# Terraform Setup

## Backend

This assumes a Bucket is setup OCI object storage to use for the Terraform state, which is accessed via HTTP and a pre-authenticated request. (See the [Oracle docs](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformUsingObjectStore.htm#http))

To configure it add a backend.conf containing: 
```
address = "{pre-authenticated request URL}/k3s_tf_state"
update_method = "PUT"
```

Then run terraform init -backend-config=backend.conf to initialize.

## Variables

This needs you to define a set of tf variables to connect to your OCI account and configure the created network and compute instances.

You need to define the following in a .tfvars file or env vars:

```
api_fingerprint      = {from your OCI API Key}
api_private_key_path = {path to your OCI API Key pem file}
tenancy_id           = {your OCI tenancy}
compartment_id       = {your OCI compartment}
user_id              = {your OCI user}
region               = {your OCI region}
ssh_key_path         = {path to the ssh public key wish to access the compute instances with}
```

# Cluster Access - via main node IP

ssh into the main node and copy the config.yaml from /k3os/system/config.yaml to /var/lib/rancher/k3os/config.yaml
> see https://github.com/rancher/k3os/blob/master/README.md#configuration

Reload k3s (e.g. reboot) the instance and connect back to it

Force-add the new SAN by force resolving it: 
```sh
curl -vk --resolve {public ip}:6443:127.0.0.1  https://{public ip}:6443/ping
```
> see https://github.com/k3s-io/k3s/issues/3369#issuecomment-849005179

Exit back to your machine and get the kube config from the main node: 
```sh
scp rancher@{public ip}:/etc/rancher/k3s/k3s.yaml ~/.kube/config
```

Open ~/.kube/config and replace the local IP configured in cluster.server with the public one. 

> see https://docs.k3s.io/cluster-access#accessing-the-cluster-from-outside-with-kubectl