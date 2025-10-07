#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up local PQ devnet...${NC}"

# Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p config/keys
mkdir -p genesis
mkdir -p leanview-data

# Use local image if available, otherwise use remote
REAM_IMAGE=${REAM_IMAGE:-"ghcr.io/reamlabs/ream:latest"}
echo "Using Docker image: ${REAM_IMAGE}"

# Generate 6 private keys for the nodes
echo -e "${YELLOW}Generating private keys for 6 nodes...${NC}"
for i in {0..5}; do
    echo "Generating private key for ${i}th node..."
    docker run --rm -v $(pwd)/config/keys:/keys ${REAM_IMAGE} \
        generate_private_key --output-path /keys/node${i}.key
done

# Read the generated private keys
declare -a PRIVATE_KEYS
for i in {0..5}; do
    PRIVATE_KEYS[$i]=$(cat config/keys/node${i}.key)
    echo "Node ${i} private key: ${PRIVATE_KEYS[$i]:0:20}..."
done

# Generate validator-config.yaml
echo -e "${YELLOW}Generating validator-config.yaml...${NC}"
cat > ./genesis/validator-config.yaml << EOF
shuffle: roundrobin
validators:
EOF

# Ream: node 0, node 1
for i in {0..1}; do
    NODE_IP="172.20.0.$((10 + i))"
    NODE_PORT=9000  # All nodes use port 9000 internally

    cat >> ./genesis/validator-config.yaml << EOF
  - name: "ream_${i}"
    privkey: "${PRIVATE_KEYS[$i]}"
    enrFields:
      ip: "${NODE_IP}"
      quic: ${NODE_PORT}
      seq: 1
    count: 1

EOF
done

# Zeam: node 2, 3
for i in {2..3}; do
    NODE_IP="172.20.0.$((10 + i))"
    NODE_PORT=9000  # All nodes use port 9000 internally

    cat >> ./genesis/validator-config.yaml << EOF
  - name: "zeam_${i}"
    privkey: "${PRIVATE_KEYS[$i]}"
    enrFields:
      ip: "${NODE_IP}"
      quic: ${NODE_PORT}
      seq: 1
    count: 1

EOF
done

# Qlean: node 4, 5
for i in {4..5}; do
    NODE_IP="172.20.0.$((10 + i))"
    NODE_PORT=9000  # All nodes use port 9000 internally

    cat >> ./genesis/validator-config.yaml << EOF
  - name: "qlean_${i}"
    privkey: "${PRIVATE_KEYS[$i]}"
    enrFields:
      ip: "${NODE_IP}"
      quic: ${NODE_PORT}
      seq: 1
    count: 1

EOF
done

echo "validator-config.yaml generated successfully"

# Generate config.yaml with genesis time (1 minute buffer)
echo -e "${YELLOW}Generating config.yaml with genesis time...${NC}"
GENESIS_TIME=$(($(date +%s) + 60))

# Handle different date command syntax for Linux vs macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD date)
    echo "Genesis time set to: $(date -r ${GENESIS_TIME} '+%Y-%m-%d %H:%M:%S') (1 minute from now)"
else
    # Linux (GNU date)
    echo "Genesis time set to: $(date -d @${GENESIS_TIME} '+%Y-%m-%d %H:%M:%S') (1 minute from now)"
fi

cat > config.yaml << EOF
# Genesis Settings
GENESIS_TIME: ${GENESIS_TIME}

# Validator Settings
VALIDATOR_COUNT: 0 # This will be updated
EOF

echo "config.yaml generated successfully"

# Run eth-genesis-state-generator
echo -e "${YELLOW}Running eth-genesis-state-generator...${NC}"

docker run --rm -v $(pwd):/data -it ethpandaops/eth-beacon-genesis:pk910-leanchain leanchain \
    --config /data/config.yaml \
    --mass-validators /data/genesis/validator-config.yaml \
    --state-output /data/genesis/genesis.ssz \
    --json-output /data/genesis/genesis.json \
    --nodes-output /data/genesis/nodes.yaml \
    --validators-output /data/genesis/validators.yaml \
    --config-output /data/genesis/config.yaml

echo -e "${GREEN}Genesis state generation complete!${NC}"
echo ""
echo "Generated files:"
echo "  - config/keys/node*.key (6 private keys)"
echo "  - config.yaml"
echo "  - genesis/genesis.json"
echo "  - genesis/genesis.ssz"
echo "  - genesis/config.yaml"
echo "  - genesis/nodes.yaml"
echo "  - genesis/validators.yaml"
echo "  - genesis/validator-config.yaml"
echo ""
echo -e "${GREEN}Setup complete! You can now run the nodes with docker-compose.${NC}"
