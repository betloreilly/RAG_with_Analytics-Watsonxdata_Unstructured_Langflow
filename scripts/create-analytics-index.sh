#!/bin/bash

# Create rag_analytics index in OpenSearch
# This script creates the analytics index needed for monitoring

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load environment variables
if [ -f ".env" ]; then
    # Source the .env file
    set -a
    source .env
    set +a
    echo -e "${GREEN}Loaded credentials from .env${NC}"
else
    echo -e "${RED}ERROR: .env file not found${NC}"
    echo "Please create .env file with your OpenSearch credentials"
    exit 1
fi

# Validate credentials
if [ -z "$OPENSEARCH_URL" ]; then
    echo -e "${RED}ERROR: OPENSEARCH_URL not set in .env${NC}"
    exit 1
fi

if [ -z "$OPENSEARCH_USERNAME" ] || [ -z "$OPENSEARCH_PASSWORD" ]; then
    echo -e "${RED}ERROR: OPENSEARCH_USERNAME and OPENSEARCH_PASSWORD not set in .env${NC}"
    exit 1
fi

echo -e "${GREEN}Creating rag_analytics index...${NC}"

# Create rag_analytics index
HTTP_STATUS=$(curl -s -o /tmp/opensearch_response.txt -w "%{http_code}" \
    -X PUT "${OPENSEARCH_URL}/rag_analytics" \
    -u "${OPENSEARCH_USERNAME}:${OPENSEARCH_PASSWORD}" \
    -H 'Content-Type: application/json' \
    -d '{
      "settings": {
        "index": {
          "number_of_shards": 1,
          "number_of_replicas": 1
        }
      },
      "mappings": {
        "properties": {
          "id": { "type": "keyword" },
          "session_id": { "type": "keyword" },
          "question": { "type": "text" },
          "answer": { "type": "text" },
          "timestamp": { "type": "date" },
          "latency_ms": { "type": "long" },
          "quality_score": { "type": "float" },
          "quality_label": { "type": "keyword" },
          "needs_improvement": { "type": "boolean" },
          "improvement_reason": { "type": "text" },
          "category": { "type": "keyword" },
          "subcategory": { "type": "keyword" },
          "topics": { "type": "keyword" },
          "question_type": { "type": "keyword" },
          "question_complexity": { "type": "keyword" },
          "answer_length": { "type": "integer" },
          "has_citations": { "type": "boolean" },
          "confidence_expressed": { "type": "boolean" },
          "sources_count": { "type": "integer" },
          "sources": {
            "type": "nested",
            "properties": {
              "filename": { "type": "keyword" },
              "relevance_score": { "type": "float" }
            }
          },
          "user_rating": { "type": "integer" },
          "user_feedback": { "type": "text" },
          "model_used": { "type": "keyword" },
          "langflow_flow_id": { "type": "keyword" }
        }
      }
    }')

if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 201 ]; then
    echo -e "${GREEN}✓ Successfully created rag_analytics index${NC}"
    rm -f /tmp/opensearch_response.txt
    exit 0
elif [ "$HTTP_STATUS" -eq 400 ]; then
    if grep -q "resource_already_exists_exception" /tmp/opensearch_response.txt; then
        echo -e "${YELLOW}rag_analytics index already exists${NC}"
        rm -f /tmp/opensearch_response.txt
        exit 0
    else
        echo -e "${RED}Failed to create rag_analytics index (HTTP $HTTP_STATUS)${NC}"
        cat /tmp/opensearch_response.txt
        rm -f /tmp/opensearch_response.txt
        exit 1
    fi
else
    echo -e "${RED}Failed to create rag_analytics index (HTTP $HTTP_STATUS)${NC}"
    cat /tmp/opensearch_response.txt
    rm -f /tmp/opensearch_response.txt
    exit 1
fi
