#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Cleaning up local PQ devnet...${NC}"

# Stop and remove Docker containers
echo -e "${YELLOW}Stopping Docker containers...${NC}"
docker-compose down -v 2>/dev/null || true

# Remove Docker volumes
echo -e "${YELLOW}Removing Docker volumes...${NC}"
docker volume rm local-pq-devnet_node1-data 2>/dev/null || true
docker volume rm local-pq-devnet_node2-data 2>/dev/null || true
docker volume rm local-pq-devnet_node3-data 2>/dev/null || true
docker volume rm local-pq-devnet_node4-data 2>/dev/null || true

# Remove generated files and directories
echo -e "${YELLOW}Removing generated files and directories...${NC}"
rm -rf config/
rm -rf genesis/
rm -f validator-config.yaml
rm -f config.yaml

# Remove any leftover Docker networks
echo -e "${YELLOW}Removing Docker network...${NC}"
docker network rm local-pq-devnet_ream-network 2>/dev/null || true

echo -e "${GREEN}Cleanup complete!${NC}"
echo ""
echo "Removed:"
echo "  - Docker containers and volumes"
echo "  - config/ directory (including private keys)"
echo "  - genesis/ directory"
echo "  - validator-config.yaml"
echo "  - config.yaml"
echo ""
echo -e "${GREEN}You can now run ./setup-genesis.sh to start fresh.${NC}"