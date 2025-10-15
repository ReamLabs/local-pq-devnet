# local-pq-devnet

Local development network for running lean nodes with Docker Compose.

## Quick Start

### 1. Setup genesis and configuration

```bash
# Generate private keys, validator configs, and genesis state
./setup-genesis.sh
```

### 2. Run the the network

```bash
# Start all nodes
docker-compose up -d

# View logs
docker-compose logs -f

# Access lean node APIs
curl http://localhost:5052/lean/v0/head  # Node 0
curl http://localhost:5053/lean/v0/head  # Node 1
# and so on...
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
- **Nodes**: 6 nodes with 1 validator each
- **Ports**:
  - P2P: 9000-9005 (QUIC)
  - API: 5052-5057 (HTTP)
  - Metrics: 8080-8085
