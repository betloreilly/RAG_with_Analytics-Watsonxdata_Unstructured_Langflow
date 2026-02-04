#!/bin/bash

# RAG Pipeline with Monitoring & Analytics - Setup Script
# This script automates the installation and configuration process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo "================================================"
    echo "$1"
    echo "================================================"
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get user confirmation
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Main setup
main() {
    print_header "RAG Pipeline Setup - watsonx.data OpenSearch"
    
    log_info "This script will set up your RAG pipeline with monitoring capabilities."
    echo ""
    
    # Step 1: Check prerequisites
    print_header "Step 1: Checking Prerequisites"
    
    # Check Python
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        log_success "Python ${PYTHON_VERSION} is installed"
    else
        log_error "Python 3.9+ is required but not found"
        log_info "Please install Python from https://www.python.org/downloads/"
        exit 1
    fi
    
    # Check pip
    if command_exists pip3; then
        log_success "pip3 is installed"
    else
        log_error "pip3 is required but not found"
        exit 1
    fi
    
    # Check Node.js
    if command_exists node; then
        NODE_VERSION=$(node --version)
        log_success "Node.js ${NODE_VERSION} is installed"
    else
        log_warning "Node.js is not installed"
        log_info "Please install Node.js 18+ from https://nodejs.org/"
        if ! confirm "Continue without Node.js? (you'll need it for the frontend)"; then
            exit 1
        fi
    fi
    
    # Check npm
    if command_exists npm; then
        NPM_VERSION=$(npm --version)
        log_success "npm ${NPM_VERSION} is installed"
    else
        if command_exists node; then
            log_warning "npm not found (should come with Node.js)"
        fi
    fi
    
    # Step 2: Python Virtual Environment
    print_header "Step 2: Setting Up Python Environment"
    
    if [ -d "venv" ]; then
        log_warning "Virtual environment 'venv' already exists"
        if confirm "Recreate virtual environment?"; then
            rm -rf venv
            log_info "Creating Python virtual environment..."
            python3 -m venv venv
            log_success "Virtual environment created"
        else
            log_info "Using existing virtual environment"
        fi
    else
        log_info "Creating Python virtual environment..."
        python3 -m venv venv
        log_success "Virtual environment created"
    fi
    
    # Activate virtual environment
    log_info "Activating virtual environment..."
    source venv/bin/activate
    
    # Upgrade pip
    log_info "Upgrading pip..."
    pip install --upgrade pip --quiet
    
    # Step 3: Install Python Dependencies
    print_header "Step 3: Installing Python Dependencies"
    
    if [ -f "requirements.txt" ]; then
        log_info "Installing Python packages from requirements.txt..."
        pip install -r requirements.txt --quiet
        log_success "Python packages installed"
    else
        log_warning "requirements.txt not found"
    fi
    
    # Step 4: Install Langflow
    print_header "Step 4: Installing Langflow"
    
    if pip show langflow >/dev/null 2>&1; then
        LANGFLOW_VERSION=$(pip show langflow | grep Version | cut -d' ' -f2)
        log_success "Langflow ${LANGFLOW_VERSION} is already installed"
        if confirm "Reinstall Langflow?"; then
            log_info "Installing Langflow..."
            pip install langflow --upgrade --quiet
            log_success "Langflow updated"
        fi
    else
        log_info "Installing Langflow... (this may take a few minutes)"
        pip install langflow --quiet
        log_success "Langflow installed"
    fi
    
    # Step 5: Environment Configuration
    print_header "Step 5: Configuring Environment Variables"
    
    if [ -f ".env" ]; then
        log_warning ".env file already exists"
        if ! confirm "Do you want to reconfigure environment variables?"; then
            log_info "Skipping environment configuration"
        else
            configure_env
        fi
    else
        log_info "Creating .env file from template..."
        cp env-example.txt .env
        log_success ".env file created"
        configure_env
    fi
    
    # Step 6: Create OpenSearch Indices
    print_header "Step 6: Creating OpenSearch Indices"
    
    if [ ! -z "$OPENSEARCH_URL" ] && [ ! -z "$OPENSEARCH_USERNAME" ] && [ ! -z "$OPENSEARCH_PASSWORD" ]; then
        create_opensearch_indices
    else
        log_warning "OpenSearch credentials not configured, skipping index creation"
        log_info "You can create indices manually later - see README.md"
    fi
    
    # Step 7: Start Langflow and Import Flow
    print_header "Step 7: Starting Langflow"
    
    start_langflow
    
    # Step 8: Frontend Setup
    print_header "Step 8: Setting Up Frontend"
    
    if command_exists npm; then
        cd frontend
        
        log_info "Frontend loads .env from project root (see next.config.js)"
        
        # Install npm packages
        if [ -d "node_modules" ]; then
            log_warning "node_modules already exists"
            if confirm "Reinstall npm packages?"; then
                log_info "Installing npm packages... (this may take a few minutes)"
                npm install
                log_success "npm packages installed"
            else
                log_info "Skipping npm install"
            fi
        else
            log_info "Installing npm packages... (this may take a few minutes)"
            npm install
            log_success "npm packages installed"
        fi
        
        cd ..
    else
        log_warning "Skipping frontend setup (Node.js/npm not found)"
    fi
    
    # Step 9: Summary and Next Steps
    print_header "Setup Complete!"
    
    log_success "Your RAG pipeline is configured and ready to use!"
    echo ""
    
    log_success "Langflow is running at http://localhost:7861 (no authentication required)"
    echo ""
    
    echo "Next Steps:"
    echo ""
    echo "1. Import Langflow Flow:"
    echo "   - Open http://localhost:7861"
    echo "   - Import 'RAG with Opensearch.json'"
    echo "   - Update OpenSearch credentials in the flow"
    echo "   - Copy the Flow ID and update LANGFLOW_FLOW_ID in .env"
    echo ""
    echo "2. Ingest documents:"
    echo "   source venv/bin/activate"
    echo "   python scripts/ingest_unstructured_opensearch.py --dir ./data"
    echo ""
    echo "3. Start the frontend:"
    echo "   cd frontend"
    echo "   npm run dev"
    echo "   Open http://localhost:3000"
    echo ""
    echo "4. Access Services:"
    echo "   - Chat UI: http://localhost:3000"
    echo "   - Langflow: http://localhost:7861"
    echo "   - OpenSearch Dashboards: ${OPENSEARCH_DASHBOARDS_URL}"
    echo ""
    echo "5. View Analytics:"
    echo "   - Chat UI Analytics: http://localhost:3000/analytics"
    echo "   - OpenSearch Dashboards: ${OPENSEARCH_DASHBOARDS_URL}"
    echo ""
    log_info "Langflow is running in the background (PID in langflow.pid)"
    log_info "To stop: kill \$(cat langflow.pid)"
    log_info "For more details, see README.md"
    echo ""
}

# Configure main .env file
configure_env() {
    echo ""
    log_info "Let's configure your environment variables..."
    echo ""
    
    # OpenSearch URL
    read -p "Enter your watsonx.data OpenSearch URL (e.g., https://your-instance.com:9200): " OPENSEARCH_URL
    if [ ! -z "$OPENSEARCH_URL" ]; then
        sed -i.bak "s|OPENSEARCH_URL=.*|OPENSEARCH_URL=$OPENSEARCH_URL|" .env
        export OPENSEARCH_URL
    fi
    
    # OpenSearch Username
    read -p "Enter your OpenSearch username: " OPENSEARCH_USERNAME
    if [ ! -z "$OPENSEARCH_USERNAME" ]; then
        sed -i.bak "s|OPENSEARCH_USERNAME=.*|OPENSEARCH_USERNAME=$OPENSEARCH_USERNAME|" .env
        export OPENSEARCH_USERNAME
    fi
    
    # OpenSearch Password
    read -sp "Enter your OpenSearch password: " OPENSEARCH_PASSWORD
    echo ""
    if [ ! -z "$OPENSEARCH_PASSWORD" ]; then
        sed -i.bak "s|OPENSEARCH_PASSWORD=.*|OPENSEARCH_PASSWORD=$OPENSEARCH_PASSWORD|" .env
        export OPENSEARCH_PASSWORD
    fi
    
    # OpenSearch Dashboards URL (with NEXT_PUBLIC_ prefix for browser access)
    if [ ! -z "$OPENSEARCH_URL" ]; then
        OPENSEARCH_DASHBOARDS_URL=$(echo $OPENSEARCH_URL | sed 's/:9200/:5601/')
        sed -i.bak "s|NEXT_PUBLIC_OPENSEARCH_DASHBOARDS_URL=.*|NEXT_PUBLIC_OPENSEARCH_DASHBOARDS_URL=$OPENSEARCH_DASHBOARDS_URL|" .env
        export NEXT_PUBLIC_OPENSEARCH_DASHBOARDS_URL=$OPENSEARCH_DASHBOARDS_URL
        log_info "Derived Dashboards URL: $OPENSEARCH_DASHBOARDS_URL"
    fi
    
    # OpenAI API Key
    read -sp "Enter your OpenAI API key: " OPENAI_API_KEY
    echo ""
    if [ ! -z "$OPENAI_API_KEY" ]; then
        sed -i.bak "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=$OPENAI_API_KEY|" .env
        export OPENAI_API_KEY
    fi
    
    # Unstructured API Key
    read -sp "Enter your Unstructured.io API key: " UNSTRUCTURED_API_KEY
    echo ""
    if [ ! -z "$UNSTRUCTURED_API_KEY" ]; then
        sed -i.bak "s|UNSTRUCTURED_API_KEY=.*|UNSTRUCTURED_API_KEY=$UNSTRUCTURED_API_KEY|" .env
        export UNSTRUCTURED_API_KEY
    fi
    
    # Add Langflow URL and Flow ID placeholders if not present
    if ! grep -q "LANGFLOW_URL" .env; then
        echo "LANGFLOW_URL=http://localhost:7861" >> .env
    fi
    if ! grep -q "LANGFLOW_FLOW_ID" .env; then
        echo "LANGFLOW_FLOW_ID=" >> .env
    fi
    
    # Clean up backup files
    rm -f .env.bak
    
    log_success "Environment variables configured in .env"
}

# Create OpenSearch indices
create_opensearch_indices() {
    log_info "Creating OpenSearch indices..."
    
    # Read credentials from .env
    if [ -f ".env" ]; then
        set -a
        source .env
        set +a
    fi
    
    # Validate credentials
    if [ -z "$OPENSEARCH_URL" ] || [ -z "$OPENSEARCH_USERNAME" ] || [ -z "$OPENSEARCH_PASSWORD" ]; then
        log_warning "OpenSearch credentials not fully configured"
        return 1
    fi
    
    # Create hybrid_demo index for document ingestion
    log_info "Creating 'hybrid_demo' index for document ingestion..."
    
    HTTP_STATUS=$(curl -s -o /tmp/opensearch_response.txt -w "%{http_code}" \
        -X PUT "${OPENSEARCH_URL}/hybrid_demo" \
        -u "${OPENSEARCH_USERNAME}:${OPENSEARCH_PASSWORD}" \
        -H 'Content-Type: application/json' \
        -d '{
          "settings": {
            "index": {
              "knn": true,
              "number_of_shards": 1,
              "number_of_replicas": 1
            }
          },
          "mappings": {
            "properties": {
              "vector_field": {
                "type": "knn_vector",
                "dimension": 1536,
                "method": {
                  "name": "hnsw",
                  "space_type": "cosinesimil",
                  "engine": "lucene"
                }
              },
              "text": {
                "type": "text"
              },
              "keywords": {
                "type": "text"
              },
              "title": {
                "type": "text"
              },
              "metadata": {
                "type": "object",
                "enabled": true
              }
            }
          }
        }')
    
    if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 201 ]; then
        log_success "Created 'hybrid_demo' index"
    elif [ "$HTTP_STATUS" -eq 400 ]; then
        if grep -q "resource_already_exists_exception" /tmp/opensearch_response.txt; then
            log_warning "'hybrid_demo' index already exists"
        else
            log_error "Failed to create 'hybrid_demo' index (HTTP $HTTP_STATUS)"
            cat /tmp/opensearch_response.txt
        fi
    else
        log_error "Failed to create 'hybrid_demo' index (HTTP $HTTP_STATUS)"
        cat /tmp/opensearch_response.txt
    fi
    
    # Create rag_analytics index using shared script (single source of truth)
    log_info "Creating 'rag_analytics' index for monitoring..."
    if [ -f "scripts/create-analytics-index.sh" ]; then
        if ./scripts/create-analytics-index.sh; then
            log_success "rag_analytics index ready"
        else
            log_error "Failed to create rag_analytics index (see above)"
            return 1
        fi
    else
        log_warning "scripts/create-analytics-index.sh not found, skipping rag_analytics"
    fi
    
    rm -f /tmp/opensearch_response.txt
    
    log_success "OpenSearch indices ready!"
}

# Start Langflow and import flow
start_langflow() {
    log_info "Starting Langflow without authentication..."
    
    # Check if Langflow is already running
    if [ -f "langflow.pid" ]; then
        OLD_PID=$(cat langflow.pid)
        if ps -p $OLD_PID > /dev/null 2>&1; then
            log_warning "Langflow is already running (PID: $OLD_PID)"
            if ! confirm "Stop and restart Langflow?"; then
                log_info "Using existing Langflow instance"
                LANGFLOW_URL="http://localhost:7861"
                import_langflow_flow
                return
            else
                log_info "Stopping existing Langflow instance..."
                kill $OLD_PID 2>/dev/null || true
                sleep 2
            fi
        fi
    fi
    
    # Start Langflow in background without authentication
    log_info "Launching Langflow (this may take 30-60 seconds)..."
    
    source venv/bin/activate
    export LANGFLOW_SKIP_AUTH_AUTO_LOGIN=true
    nohup langflow run --host 0.0.0.0 --port 7861 > langflow.log 2>&1 &
    LANGFLOW_PID=$!
    echo $LANGFLOW_PID > langflow.pid
    
    log_info "Langflow starting (PID: $LANGFLOW_PID)..."
    log_info "Waiting for Langflow to be ready..."
    
    # Wait for Langflow to be ready (max 120 seconds)
    LANGFLOW_URL="http://localhost:7861"
    MAX_WAIT=120
    ELAPSED=0
    
    while [ $ELAPSED -lt $MAX_WAIT ]; do
        if curl -s -f "${LANGFLOW_URL}/health" > /dev/null 2>&1; then
            log_success "Langflow is ready!"
            break
        fi
        sleep 2
        ELAPSED=$((ELAPSED + 2))
        if [ $((ELAPSED % 10)) -eq 0 ]; then
            log_info "Still waiting... (${ELAPSED}s elapsed)"
        fi
    done
    
    if [ $ELAPSED -ge $MAX_WAIT ]; then
        log_error "Langflow failed to start within ${MAX_WAIT} seconds"
        log_info "Check langflow.log for details"
        return 1
    fi
    
    # Provide instructions for manual flow import
    log_info ""
    log_warning "IMPORTANT: Configure Langflow manually:"
    log_info ""
    log_info "1. IMPORT THE FLOW:"
    log_info "   - Open http://localhost:7861 (no login required)"
    log_info "   - Look for 'Upload' button/icon on the LEFT sidebar"
    log_info "   - Click Upload and select 'RAG with Opensearch.json' from this directory"
    log_info "   - Or drag and drop the JSON file into the main canvas"
    log_info ""
    log_info "2. SET GLOBAL VARIABLES (OpenAI API Key):"
    log_info "   - Click the ⚙️ Settings icon (top-right corner)"
    log_info "   - Go to 'Global Variables' or 'Variables' section"
    log_info "   - Add variable: OPENAI_API_KEY"
    log_info "   - Value: Your OpenAI API key"
    log_info "   - Save"
    log_info ""
    log_info "3. CONFIGURE OPENSEARCH COMPONENT:"
    log_info "   - Find the OpenSearch component in the flow canvas"
    log_info "   - Click on it to open settings"
    log_info "   - Set: URL = ${OPENSEARCH_URL}"
    log_info "   - Set: Username = ${OPENSEARCH_USERNAME}"
    log_info "   - Set: Password = ${OPENSEARCH_PASSWORD}"
    log_info "   - Set: Index Name = hybrid_demo"
    log_info "   - Save the component"
    log_info ""
    log_info "4. GET FLOW ID:"
    log_info "   - Look at the browser URL bar"
    log_info "   - Flow ID is the last part: .../flow/YOUR-FLOW-ID"
    log_info "   - Copy the Flow ID"
    log_info "   - Update LANGFLOW_FLOW_ID in .env file"
    log_info ""
}

# This function has been removed - automatic flow import is not reliable
# across different Langflow versions. Manual import instructions are provided instead.

# Frontend env configuration function removed - using single .env file at root

# Run main function
main
