# local-pq-devnet

Local development network for running 4 ream lean nodes with Docker Compose.

## Quick Start

### 1. Setup genesis and configuration

```bash
# Generate private keys, validator configs, and genesis state
./setup-genesis.sh
```

This script will:

- ✅ Generate four `secp256k1` private keys using `ream generate_private_key`
- ✅ Create `validator-config.yaml` with hex-encoded private keys
  - Nodes named `ream_0` through `ream_3`
  - Each node on internal IP `172.20.0.10-13` with port `9000`
  - Each node has **1** validator (4 total)
- ✅ Create `config.yaml` with genesis time (1 minute buffer)
- ✅ Run `eth-genesis-state-generator` using Docker

### 2. Run the 4-node network

```bash
# Start all 4 nodes
docker-compose up -d

# View logs
docker-compose logs -f

# Access lean node APIs
curl http://localhost:5052/lean/v0/head  # Node 0
curl http://localhost:5053/lean/v0/head  # Node 1
curl http://localhost:5054/lean/v0/head  # Node 2
curl http://localhost:5055/lean/v0/head  # Node 3
```

### 3. Cleanup

```bash
# Stop nodes and remove all generated files
./cleanup.sh
```

## Using Local Docker Image

```bash
# Build local image (if you have ream source)
docker build -t ream:local /path/to/ream

# Use local image
REAM_IMAGE=ream:local ./setup-genesis.sh
REAM_IMAGE=ream:local docker-compose up
```

## Network Configuration

- **Network**: `172.20.0.0/24`
- **Nodes**: 4 nodes with 1 validator each
- **Ports**:
  - P2P: 9000-9003 (QUIC)
  - API: 5052-5055 (HTTP)
  - Metrics: 8080-8083
