# erpc-helm
A Helm chart for E-RPC node based on Nethermind client

## Prerequisites
1. Installed https://github.com/bitnami-labs/sealed-secrets for creating SealedSecret resources (for using DID-Auth feature, not mandratory for simple install).
2. Enable FeatureGate `MixedProtocolLBService=true` to use TCP and UDP ports in the same NLB. It should be enabled via kubelet extra args.
3. Installed https://github.com/kubernetes-sigs/aws-load-balancer-controller/ for creating NLB.

## Requirements
| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | nginx | 10.2.1 |
| https://charts.bitnami.com/bitnami | redis | 16.4.0 |

## Simple install
### EWC chain 
#### FastSync:
Run parametrized Helm install with:

    helm install --namespace <namespace> --create-namespace \
    --set node.fastSync=true --set node.chain=ewc \
    --set node.chainspecURL=https://raw.githubusercontent.com/energywebfoundation/ewf-chainspec/master/EnergyWebChain.json \
    --set node.genesisHash=0x0b6d3e680af2fc525392c720666cce58e3d8e6fe75ba4b48cb36bcc69039229b \
    --set node.pivotNumber=16400000 --set node.pivotHash=0x1c62742497b3d0eb286589b9caf0d895f3aa0466978b44f55fb6f3e8030ccd07 \
    --set node.pivotTotalDifficulty=5580630817503390800799343561880998667533141730 \
    <helm-chart-name> <path-to-helm-chart>

You need to set the pivot block number, hash and total difficulty from a trusted source (you can use etherscan and confirm with other sources if you wan to change it).
#### Archive:
Run parametrized Helm install with:

    helm install --namespace <namespace> --create-namespace \
    --set node.fastSync=false --set node.chain=ewc \
    --set node.chainspecURL=https://raw.githubusercontent.com/energywebfoundation/ewf-chainspec/master/EnergyWebChain.json \
    --set node.genesisHash=0x0b6d3e680af2fc525392c720666cce58e3d8e6fe75ba4b48cb36bcc69039229b \
    <helm-chart-name> <path-to-helm-chart>

### Volta chain 
#### FastSync:
Run parametrized Helm install with:

    helm install --namespace <namespace> --create-namespace \
    --set node.fastSync=true --set node.chain=volta \
    --set node.chainspecURL=https://raw.githubusercontent.com/energywebfoundation/ewf-chainspec/master/Volta.json \
    --set node.genesisHash=0xebd8b413ca7b7f84a8dd20d17519ce2b01954c74d94a0a739a3e416abe0e43e5 \
    --set node.pivotNumber=15510000 --set node.pivotHash=0x69a8ab325e93c7570a40e2275b93fe5defe08b52c75ca45319139e11cd04cf8e \
    --set node.pivotTotalDifficulty=5277779510943755568316940161266724959338720152 \
    <helm-chart-name> <path-to-helm-chart>

You need to set the pivot block number, hash and total difficulty from a trusted source (you can use etherscan and confirm with other sources if you wan to change it).
#### Archive:
Run parametrized Helm install with:

    helm install --namespace <namespace> --create-namespace \
    --set node.fastSync=true --set node.chain=volta \
    --set node.chainspecURL=https://raw.githubusercontent.com/energywebfoundation/ewf-chainspec/master/Volta.json \
    --set node.genesisHash=0xebd8b413ca7b7f84a8dd20d17519ce2b01954c74d94a0a739a3e416abe0e43e5 \
    <helm-chart-name> <path-to-helm-chart>

## Values
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"nethermind/nethermind"` | Nethermind client repository |
| image.tag | string | `"1.14.5"` | Last tested tag |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| initContainer.image.repository | string | `"crazymax/7zip"` | Initcontainer repository to download chainspec |
| initContainer.image.tag | string | `"latest"` |  |
| kubectl.image.repository | string | `"bitnami/kubectl"` | Kubectl repository |
| kubectl.image.tag | string | `"1.21"` |  |
| serviceAccount.create | bool | `true` | Enable/disable service account creation |
| serviceAccount.createRoleBinding | bool | `true` | Enable/disable creation of RBAC to access cluster resources |
| service.type | string | `"NodePort"` | To create NLB as a service for external access `NodePort` is mandratory |
| service.httpPort | int | `8545` | Nethermind HTTP port |
| service.wsPort | int | `8546` | Nethermind WebSocket port |
| service.discoveryPort | int | `30304` | Nethermind UDP discovery port |
| service.p2pPort | int | `30303` | Nethermind TCP P2P port |
| resources.limits.[] | map | `{cpu: "2048m", memory: "6144Mi"}` | Minimum required limits to run Nethermind E-RPC node |
| resources.requests.[] | map | `{cpu: "2048m", memory: "5120Mi"}` | Minimum required requests to run Nethermind E-RPC node |
| node.fastSync | bool | `true` | Enable/Disable Nethermind Fast Sync mode. If disabled - node will be archieve type |
| node.webSocketEnabled | bool | `true` | Enable/Disable WebSocket communication |
| node.replicas | int | `1` | Number of initial replicas |
| node.chainspecURL | string | `"https://raw.githubusercontent.com/energywebfoundation/ewf-chainspec/master/Volta.json"` | URL of the chainspec to download |
| node.genesisHash | string | `"0xebd8b413ca7b7f84a8dd20d17519ce2b01954c74d94a0a739a3e416abe0e43e5"` | Chain related settings |
| node.pivotNumber | int | `15510000` | Block Height to start Fast Sync from |
| node.pivotHash | string | `"0x69a8ab325e93c7570a40e2275b93fe5defe08b52c75ca45319139e11cd04cf8e"` | Block Hash to start Fast Sync from |
| node.pivotTotalDifficulty | string | `"5277779510943755568316940161266724959338720152"` | Total difficulty of the chain till specified block to start Fast Sync from |
| node.volume.size | string | `"400Gi"` | Initial Nethermind DB persistent volume size. Size of the PVC storage could be extended with `kubectl edit` command for the specified PVC |
| node.volume.snapshot | string | `""` | EBS snapshot ID to use for DB snapshot |
| didAuthProxy.enabled | bool | `true` | Enable/Disable DID-Auth proxy for accessing Nethermind API |
| didAuthProxy.image.repository | string | `"public.ecr.aws/p2b6f2f9/did-auth"` | DID-Auth proxy container repository |
| didAuthProxy.image.tag | string | `"latest"` | |
| didAuthProxy.service.type | srting | `"ClusterIP"` | Service type of DID-Auth Proxy |
| didAuthProxy.service.port | int | `80` | Port number of DID-Auth Proxy service |
| didAuthProxy.appValues.PORT | int | `80` | Port number of DID-Auth Proxy instance |
| didAuthProxy.appValues.ACCEPTED_ROLES | string | `""` | Comma separated list of the roles that allowed to authorize through DID-Auth Proxy |
| didAuthProxy.appValues.JWT_ACCESS_TTL | int | `3600` | DID-Auth Proxy Access token TTL |
| didAuthProxy.appValues.JWT_REFRESH_TTL | int | `86400` | DID-Auth Proxy Refresh token TTL |
| didAuthProxy.opsValues.RPC_URL | string | `"https://volta-rpc.energyweb.org/"` | |
| didAuthProxy.opsValues.CACHE_SERVER_URL | string | `"https://identitycache-dev.energyweb.org/v1"` | |
| didAuthProxy.opsValues.REDIS_PORT | int | `6379` | Port of the internal Redis Cache server |
| didAuthProxy.sealedSecret.enabled | bool | `true` | Enable/Disable creation of SealedSecret with `bitnami/sealed-secrets-controller` |
| didAuthProxy.sealedSecret.name | string | `"did-auth-sealedsecret"` | The name of SealedSecret resource |
| didAuthProxy.sealedSecret.annotations.[] | map | | Annotation for SealedSecret resource (see the [docs](https://github.com/bitnami-labs/sealed-secrets)) |
| didAuthProxy.sealedSecret.encryptedData.[] | map | | Array of `key:value` secrets to be stored with SealedSecret |
| redis.architecture | string | `"standalone"` | Type of Redis cache instance |
| redis.auth.existingSecret | string | `"did-auth-sealedsecret"` | The name of SealedSecret resource defined in `didAuthProxy.sealedSecret.name` |
| redis.auth.existingSecretPasswordKey | string | `"REDIS_PASSWORD"` | Key at SealedSecret resource to store Redis password |
| nginx.existingServerBlockConfigmap | string | `"did-auth-nginx-configmap"` | Configmap to store nginx config for DID-Auth Proxy |
| nginx.ingress.enabled | bool | `false` | Enabel/Disable ingress for DID-Auth Proxy Nginx instance |
| nginx.ingress.annotations.[] | map | | Annotations for Ingress controller for DID-Auth Proxy Nginx |