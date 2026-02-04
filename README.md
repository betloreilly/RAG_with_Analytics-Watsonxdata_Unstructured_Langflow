# RAG Pipeline with Monitoring & Analytics

**Repository:** `RAG_with_Analytics-Watsonxdata_Unstructured_Langflow`

A RAG system with built-in quality monitoring, analytics dashboards, and automated LLM-based evaluation.

Unlike basic RAG demos, this project includes observability through OpenSearch Dashboards, giving you real-time insights into answer quality, user behavior, and system performance.

## What Makes This Different from Other RAG Demos

Most RAG repositories focus only on retrieval and generation. This project adds **observability** using OpenSearch's built-in analytics capabilities.

### Key Differentiators

**LLM-as-a-Judge Quality Analysis**
- Automatic evaluation of every answer with quality scores (0-1)
- Categorization: good/fair/poor with specific improvement reasons
- Runs asynchronously to avoid impacting response time

**OpenSearch Dashboards Integration**
- Pre-built visualizations for quality trends and patterns
- Question categorization (Technical, Business, Research, etc.)
- Performance monitoring (latency, response time)
- No separate analytics infrastructure needed—leverage OpenSearch

**Actionable Insights**
- Identify gaps: which questions consistently get poor answers
- Track improvements: see quality trends after adding documents
- Understand usage: what topics users ask about most
- Prioritize work: focus on high-impact improvements

![RAG Analytics Dashboard](/data/monitor.png)
*Real-time monitoring: quality distribution, question categories, latency tracking, and questions flagged for improvement*

### Comparison with Basic RAG Demos

| Feature | Basic RAG Demo | **This Repo** |
|---------|----------------|---------------|
| Q&A Functionality | Yes | Yes |
| Vector Search | Yes | Yes (Hybrid: Vector + BM25 + Boosting) |
| Quality Monitoring | No | Yes (Automatic LLM-as-a-Judge) |
| Analytics Dashboard | No | Yes (Pre-built OpenSearch Dashboards) |
| Question Categorization | No | Yes (Technical, Business, etc.) |
| Improvement Tracking | No | Yes (Track quality trends over time) |
| Identify Gaps | Manual testing | Automatic flagging of poor answers |
| Performance Metrics | No | Yes (Latency tracking per interaction) |

### When to Use This Repo

**Use this if you need:**
- A RAG system with built-in monitoring and analytics
- Automatic quality evaluation to catch bad answers
- Insights to continuously improve your RAG system

**Use a simpler demo if:**
- You're just learning RAG basics
- You don't need monitoring or analytics
- You want minimal setup complexity

## System Architecture

![System Architecture](/data/OpensearchRAG.png)

This system combines best-in-class tools for a complete, observable RAG pipeline:

| Component | Purpose | Why It Matters |
|-----------|---------|----------------|
| **Langflow** | Visual RAG orchestration | Build flows without code, easy iteration |
| **watsonx.data OpenSearch** | Vector store + analytics database | Hybrid search (BM25 + k-NN) + built-in dashboards |
| **Unstructured.io** | Document parsing | Preserves structure (headers, tables), intelligent chunking |
| **Next.js** | Chat UI + API | Modern interface with server-side analytics processing |
| **LLM-as-a-Judge** | Quality analysis | GPT-4o-mini evaluates answers asynchronously |
| **OpenSearch Dashboards** | Visualization | Pre-built analytics dashboards, no separate tools needed |

### Data Flow

1. **Ingestion**: Documents → Unstructured.io → Embeddings → OpenSearch (`hybrid_demo` index)
2. **Query**: Question → Hybrid search (vector + BM25 + keyword boost) → Context retrieval
3. **Generation**: Context + Question → LLM → Answer
4. **Monitoring**: Question + Answer → LLM-as-a-Judge → Quality metrics → `rag_analytics` index
5. **Visualization**: OpenSearch Dashboards reads `rag_analytics` → Real-time insights

![Langflow Interface](data/demo_docs/langflow.gif)
*Visual flow builder makes it easy to modify retrieval strategies and prompts*

## Why Monitoring Matters for RAG

Most RAG demos stop at "does it answer questions?" This project goes further by answering:
- **How good are the answers?** Track quality scores and trends over time
- **Where are the gaps?** Identify topics with poor responses that need more documents
- **What are users asking?** Understand question patterns and categories
- **Is it getting better?** Monitor improvements after adding documents or tuning prompts

OpenSearch Dashboards provides a unified view of all RAG interactions, making it easy to spot issues and measure improvements.

---

## Prerequisites

**What you need before you start:**

| What | Why | How to check or get it |
|------|-----|------------------------|
| **Python 3.9 or newer** | Runs ingestion and Langflow | In a terminal: `python3 --version` (or `python --version`). If missing, install from [python.org](https://www.python.org/downloads/). |
| **Node.js 18 or newer** | Runs the chat and analytics UI | In a terminal: `node --version`. If missing, install from [nodejs.org](https://nodejs.org/). |
| **OpenSearch (watsonx.data)** | Stores documents and analytics | You need: **URL** (e.g. `https://...:9200`), **username**, and **password**. Get these from your watsonx.data OpenSearch service in the IBM Cloud console. |
| **OpenAI API key** | Embeddings and answer quality checks | Create an API key at [platform.openai.com](https://platform.openai.com/api-keys). |
| **Unstructured.io API key** | Document parsing (PDF, Word, etc.) | Sign up at [unstructured.io](https://unstructured.io/) and create an API key. |
| **Python dependencies** | Ingestion script and .env loading | From the project root: `pip install -r requirements.txt`. If you get `ModuleNotFoundError: No module named 'dotenv'`, run `pip install python-dotenv`. |

Have these ready before running the setup script so you can paste them when prompted.

---

## Quick Start

This section gets you from zero to a running RAG app in two parts: **run the setup script**, then **do three follow-up steps** (import the flow in Langflow, ingest documents, start the web app).

<div style="background-color: #f6f8fa; color: #24292f; padding: 1em 1.2em; border-radius: 6px; margin: 1em 0; border-left: 4px solid #0969da;">

**Start here — quick path**

### Option 1: Quick setup with setup.sh (recommended)

The `setup.sh` script automates the installation. You can get the project in one of two ways: **clone with Git** (if you have Git and use it) or **download as a ZIP** (no Git or SSH keys required). Both are covered below.

**In short:** Get the project (clone or download ZIP) → open a terminal in the project folder → run `./setup.sh` → answer the prompts → then do the three “After setup” steps below.

**Get the project (choose one):**

- **Clone with Git** (requires Git; no GitHub account or SSH key needed for public repos):
  ```bash
  git clone https://github.com/YOUR-ORG/RAG_with_Analytics-Watsonxdata_Unstructured_Langflow.git
  cd RAG_with_Analytics-Watsonxdata_Unstructured_Langflow
  ```
  Replace the URL with your actual repository URL.

- **Or download as a ZIP** (no Git required): On the GitHub repo page, click the green **Code** button → **Download ZIP**. Unzip the file, then in a terminal run `cd` into the unzipped folder (e.g. `cd ~/Downloads/RAG_with_Analytics-Watsonxdata_Unstructured_Langflow-main`). See Step 2 below for full details.

Then run `./setup.sh` (and if you used the ZIP, run `chmod +x setup.sh` first if you get “Permission denied”).

---

#### Step 1: Open a terminal

You’ll type all commands in a **terminal** (command line):

- **macOS:** Open **Terminal** (Applications → Utilities) or iTerm.
- **Windows:** Open **PowerShell** or **Command Prompt** (e.g. search for “PowerShell” in the Start menu).
- **Linux:** Open your distribution’s **Terminal** app.

---

#### Step 2: Get the project on your machine

Choose **one** of these.

**A) Clone with Git (if you use Git)**

In the terminal, run (replace the URL with your actual repository URL):

```bash
git clone https://github.com/YOUR-ORG/RAG_with_Analytics-Watsonxdata_Unstructured_Langflow.git
cd RAG_with_Analytics-Watsonxdata_Unstructured_Langflow
```

**B) Download as a ZIP (no Git required)**

1. In your browser, go to the **GitHub repository page** for this project.
2. Click the green **Code** button (top right of the file list).
3. Click **Download ZIP**.
4. Save the ZIP file, then **unzip it** (double-click it, or right-click → Extract).
5. Remember where the unzipped folder is (e.g. `Downloads/RAG_with_Analytics-Watsonxdata_Unstructured_Langflow-main`). You’ll open the terminal in this folder in the next step.

---

#### Step 3: Go into the project folder in the terminal

- **If you cloned with Git:** You’re already in the right place after `cd RAG_with_Analytics-Watsonxdata_Unstructured_Langflow`. If not, run:
  ```bash
  cd /path/to/RAG_with_Analytics-Watsonxdata_Unstructured_Langflow
  ```
- **If you downloaded the ZIP:** Go into the unzipped folder. For example, if it’s on your Desktop:
  ```bash
  cd ~/Desktop/RAG_with_Analytics-Watsonxdata_Unstructured_Langflow-main
  ```
  Use your real path (e.g. `Downloads` instead of `Desktop` if that’s where it is).

You should now be *in* the project folder (you’ll see files like `README.md`, `setup.sh` when you run `ls` or `dir`).

---

#### Step 4: Run the setup script

Run:

```bash
./setup.sh
```

- **If you get “Permission denied”** (common after downloading the ZIP), run this once, then try again:
  ```bash
  chmod +x setup.sh
  ./setup.sh
  ```
  (`chmod +x` makes the script executable; ZIP downloads sometimes don’t keep that permission.)

The script will ask you for the items from the Prerequisites table. Have them ready so you can paste or type when prompted.

**What the script will ask you (have these ready):**

- **OpenSearch URL** – Your watsonx.data OpenSearch URL (e.g. `https://xxxx.os....ibmappdomain.cloud:9200/`).
- **OpenSearch username** – Your OpenSearch username.
- **OpenSearch password** – Your OpenSearch password.
- **OpenAI API key** – From [platform.openai.com](https://platform.openai.com/api-keys).
- **Unstructured.io API key** – From your Unstructured.io account.

The script will create a `.env` file with these values and will derive the OpenSearch Dashboards URL for you. It will also create the Python environment, install Langflow, create the OpenSearch indices, start Langflow, and install the frontend dependencies.

---

#### Step 5: After the script finishes – do these three things

When `setup.sh` completes, it will print reminders. Do the following in order:

1. **Import the RAG flow in Langflow**
   - Open your Langflow URL in your browser (no login). The URL is in `.env` as `LANGFLOW_URL` (default: **http://localhost:7860**).
   - In Langflow, use the **Upload** option on the **left sidebar** and select the file **`RAG with Opensearch.json`** from this project folder (or drag the file onto the canvas).
   - In Langflow **Settings** (gear icon), add a **Global Variable**: name `OPENAI_API_KEY`, value = your OpenAI API key.
   - In the flow, click the **OpenSearch** component and set its **URL**, **username**, **password**, and **index name** (`hybrid_demo`) to match your `.env`.

2. **Put the Flow ID into `.env`**
   - In the browser, check the address bar; it will look like `http://localhost:7860/flow/abc123-def456-...` (or the port from your `LANGFLOW_URL`). The last part is the **Flow ID**.
   - Open the project’s **`.env`** file in a text editor and set:
     ```bash
     LANGFLOW_FLOW_ID=abc123-def456-...
     ```
     (use your actual Flow ID).

3. **Ingest documents and start the web app**
   - In the terminal (in the project folder), run:
     ```bash
     source venv/bin/activate
     python scripts/ingest_unstructured_opensearch.py --dir ./data
     ```
     (On Windows: `venv\Scripts\activate` then the same `python` command.)
   - Then start the chat UI:
     ```bash
     cd frontend
     npm run dev
     ```
   - Open **http://localhost:3000** in your browser. You should see the chat and analytics.

**You’re done.** Use the chat to ask questions; the Analytics page will show quality and usage over time. OpenSearch Dashboards will be available once you set the Dashboards URL in `.env` and prepare index patterns and visualizations using the [OpenSearch Dashboards Guide](docs/OpenSearch-Dashboards-Guide.md).

**What the script does (for reference):**

- Checks for Python 3.9+ and Node.js 18+
- Creates a Python virtual environment and installs dependencies (including Langflow)
- Creates a single `.env` file and prompts you for OpenSearch and API keys
- Creates the OpenSearch indices (`hybrid_demo` and `rag_analytics`) used by the app
- Starts Langflow (no login) and prints the manual steps for importing the flow
- Installs frontend dependencies so you can run `npm run dev` in `frontend/`

For step-by-step setup **without** the script (e.g. if the script fails or you prefer to run each step yourself), see **Option 2: Manual Setup** below.

**Troubleshooting**

- The script may ask for confirmation before overwriting existing files (e.g. `.env` or `venv`). Type `y` and Enter to continue.
- **Analytics page shows “index not found” for rag_analytics:** From the project folder run `./scripts/create-analytics-index.sh`, then restart the frontend (`cd frontend` and `npm run dev` again).
- **Stop or restart Langflow:** Run `./stop-langflow.sh` to stop. To start again: `source venv/bin/activate`, then `export LANGFLOW_SKIP_AUTH_AUTO_LOGIN=true`, then run `langflow run --host 0.0.0.0 --port PORT` (use the port from `LANGFLOW_URL` in `.env`, e.g. 7860), e.g. `nohup langflow run --host 0.0.0.0 --port 7860 > langflow.log 2>&1 &`, then `echo $! > langflow.pid`. View logs with `tail -f langflow.log`.

</div>

---

### Option 2: Manual Setup

Use this if the setup script does not work on your system or you want to run each step yourself (create `.env`, Python env, indices, Langflow, frontend) without the script.

#### Step 1: Set Environment Variables

Create a `.env` file in the project root with your watsonx.data OpenSearch credentials:

```bash
# Copy the example file (single .env for everything)
cp env-example.txt .env

# Edit .env and add your watsonx.data OpenSearch details:
OPENSEARCH_URL=https://your-opensearch-instance.com:9200
OPENSEARCH_USERNAME=your-username
OPENSEARCH_PASSWORD=your-password

# Dashboards URL (NEXT_PUBLIC_ prefix makes it available to browser)
NEXT_PUBLIC_OPENSEARCH_DASHBOARDS_URL=https://your-dashboards-instance.com:5601

# Also add your API keys:
OPENAI_API_KEY=your-openai-key
UNSTRUCTURED_API_KEY=your-unstructured-key
```

**Note**: Next.js loads the root `.env` via `next.config.js` (single file for the whole project).

#### Step 2: Set Up Python Environment

Create and activate a virtual environment, then install Langflow:

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

pip install uv
uv pip install --upgrade langflow
uv pip install fastapi==0.123.6  # Required compatibility fix
```

The FastAPI downgrade addresses a known compatibility issue in the Langflow community.

#### Step 3: Create the OpenSearch Index

Create the index in your watsonx.data OpenSearch instance with the correct vector field configuration:

```bash
# Replace with your watsonx.data credentials
curl -X PUT "${OPENSEARCH_URL}/hybrid_demo" \
  -u "${OPENSEARCH_USERNAME}:${OPENSEARCH_PASSWORD}" \
  -H 'Content-Type: application/json' -d '
{
  "settings": { "index": { "knn": true } },
  "mappings": {
    "properties": {
        "vector_field": {
          "type": "knn_vector",
          "dimension": 1536,
          "method": { "name": "hnsw", "space_type": "cosinesimil", "engine": "lucene" }
      },
      "text": { "type": "text" },
      "metadata": { "type": "object", "enabled": true }
    }
  }
}
'
```

The dimension of 1536 matches OpenAI's `text-embedding-3-small` model.

**Note on k-NN Engine:** We use `lucene` as the k-NN engine because it's the most compatible with managed OpenSearch instances like watsonx.data. While `faiss` and `nmslib` engines exist, they may not be available on all OpenSearch deployments. The `lucene` engine provides excellent performance and broad compatibility.

#### Step 4: Start Langflow

```bash
LANGFLOW_SKIP_AUTH_AUTO_LOGIN=true langflow run --host 0.0.0.0 --port 7860
```

Open the URL from `LANGFLOW_URL` in `.env` in your browser (default http://localhost:7860, no login required).

#### Step 5: Import and Configure the RAG Flow

A ready-to-use RAG flow is included in this repo.

**Import the Flow:**

1. Open Langflow at the URL in `.env` (`LANGFLOW_URL`, default http://localhost:7860) (no login required)
2. Look for the **Upload** button/icon on the **LEFT sidebar**
3. Click Upload and select `RAG with Opensearch.json` from this directory
   - Or drag and drop the JSON file directly onto the canvas
4. The flow will load in the canvas

**Set Global Variables (OpenAI API Key):**

1. Click the **⚙️ Settings** icon in the top-right corner
2. Navigate to **Global Variables** or **Variables** section
3. Add a new variable:
   - **Name**: `OPENAI_API_KEY`
   - **Value**: Your OpenAI API key (from your OpenAI account)
   - **Type**: Secret (if available)
4. Click **Save**

This makes your OpenAI key available to all components in the flow without hardcoding it.

**Configure OpenSearch Component:**

1. Find the **OpenSearch** component in the flow canvas
2. Click on it to open the component settings
3. Update the following fields:
   - **URL**: `https://your-opensearch-instance.com:9200` (from your `.env`)
   - **Username**: Your OpenSearch username
   - **Password**: Your OpenSearch password
   - **Index Name**: `hybrid_demo`
4. Click **Save** or close the settings panel

**Get Your Flow ID:**

1. Look at the browser URL bar: `<LANGFLOW_URL>/flow/YOUR-FLOW-ID-HERE` (e.g. http://localhost:7860/flow/...)
2. Copy the Flow ID (the UUID at the end of the URL)
3. Update your `.env` file:
   ```bash
   LANGFLOW_FLOW_ID=your-flow-id-here
   ```

This flow includes Chat Input, OpenSearch retrieval, RAG prompt, and LLM response components pre-configured.

---

## Ingesting Documents

You have two options to ingest documents into OpenSearch:

| Option | Tool | Best For |
|--------|------|----------|
| **Langflow UI** | Visual flow builder | Quick testing, simple RAG |
| **Python Script** | `ingest_unstructured_opensearch.py` | Hybrid search with field boosting |

**Langflow UI**: Build an ingestion flow visually (File Loader → Unstructured → Embeddings → OpenSearch). Simple but only creates `text` and `vector_field`.

**Python Script**: Creates an optimized schema with `keywords`, `title`, `summary` fields and custom analyzers for better BM25 ranking. Recommended for hybrid search.

---

## Ingesting Documents with the Python Script

The `scripts/ingest_unstructured_opensearch.py` script provides a complete ingestion pipeline with proper schema for hybrid search (BM25 + Vector).

### Features

- Parses documents using Unstructured.io API
- Generates embeddings using OpenAI
- Creates optimized OpenSearch schema with custom analyzers
- Extracts keywords automatically for hybrid search boosting
- Supports PDF, DOCX, TXT, MD, and HTML files

### Usage

```bash
# Activate your virtual environment
source venv/bin/activate

# Install dependencies (see Prerequisites if you need python-dotenv)
pip install -r requirements.txt

# The script automatically loads credentials from .env file
# No need to export environment variables manually!

# Ingest the data folder
python scripts/ingest_unstructured_opensearch.py --dir ./data
```

### Index Schema

The script creates an optimized schema for hybrid search:

- `text` - Main content with custom analyzer for BM25 ranking
- `vector_field` - Embeddings for semantic search
- `keywords` - Extracted keywords with boosting for exact matches
- `title` - Document titles with higher relevance boost
- `metadata` - File info, page numbers, categories

---

## Building Flows in Langflow

### Document Ingestion Flow

Connect these components to load and index documents:

1. **File Loader** - Points to your document directory
2. **Unstructured** - Parses PDFs and extracts text
3. **Text Splitter** - Chunks documents (1000 chars, 200 overlap)
4. **Embeddings** - Generates vectors
5. **OpenSearch Vector Store** - Stores everything

For the Unstructured component, use these settings:
- API URL: `https://api.unstructuredapp.io/general/v0/general`
- Strategy: `hi_res` for best results, `fast` for speed

### RAG Query Flow

Connect these components to answer questions:

1. **Chat Input** - User's question
2. **OpenSearch Vector Store** - Retrieves relevant chunks (k=5)
3. **Prompt Template** - Combines context with question
4. **LLM** - Generates the answer
5. **Chat Output** - Displays response

Use this prompt template:

```
You are a helpful assistant that answers questions based on the provided context.

Context:
{context}

Question: {question}

Rules:
- Only use information from the context above
- If the context doesn't contain the answer, say so
- Cite sources when possible
- Be concise but thorough

Answer:
```

---

## Hybrid Search in Langflow

Hybrid search combines keyword matching (BM25) with semantic understanding (vectors) for better results. This requires an additional component to extract keywords from the user's question.

> **Note**: To effectively use hybrid search with field boosting on additional fields like `keywords` and `title`, ingest your documents using the `scripts/ingest_unstructured_opensearch.py` script. This script creates an optimized schema with custom analyzers and automatically extracts keywords for better BM25 ranking. The default Langflow ingestion only creates basic `text` and `vector_field` fields.

![Hybrid Search](data/demo_docs/hybridsearch.png)

### Flow Architecture

```
Chat Input ──┬──→ Prompt (Keyword Extractor) → LLM (gpt-4o-mini) ──┐
             │                                                      │
             ├──→ Embedding Model ─────────────────────────────────┐│
             │                                                     ││
             └──→ OpenSearch ←─────────────────────────────────────┘│
                    │         (Search Query, Embedding,             │
                    │          Hybrid Search Query) ←───────────────┘
                    ▼
               Prompt (RAG) → LLM (gpt-4o) → Chat Output
```

### Keyword Extractor Prompt

Copy this prompt into a Prompt component connected to a fast LLM like gpt-4o-mini:

```
You are a keyword extractor for OpenSearch hybrid search.

The VECTOR/SEMANTIC search is handled automatically.
Your job is ONLY to generate the KEYWORD query part with field boosting.

Question: {question}

Rules:
- Extract 1-3 CORE technical terms only
- For keywords field: use 1-2 most specific terms (exact match, boost 3)
- For text field: use the main concept only (boost 1)
- FEWER keywords = BETTER exact matching
- Output ONLY raw JSON

Format:
{{"query":{{"bool":{{"should":[{{"match":{{"text":{{"query":"<main concept>","boost":1}}}}}},{{"match":{{"keywords":{{"query":"<1-2 specific terms>","boost":3}}}}}}]}}}}}}

Examples:

Q: "What is multi-head attention?"
{{"query":{{"bool":{{"should":[{{"match":{{"text":{{"query":"multi-head attention","boost":1}}}}}},{{"match":{{"keywords":{{"query":"multi-head attention","boost":3}}}}}}]}}}}}}

Q: "What BLEU score was achieved?"
{{"query":{{"bool":{{"should":[{{"match":{{"text":{{"query":"BLEU score","boost":1}}}}}},{{"match":{{"keywords":{{"query":"BLEU","boost":3}}}}}}]}}}}}}

JSON:
```

The double braces `{{` and `}}` are required because Langflow uses single braces for variables.

### Connections

1. Chat Input → Prompt (Keyword Extractor) as `{question}`
2. Prompt → LLM → OpenSearch's `Hybrid Search Query` input
3. Chat Input → OpenSearch's `Search Query` input
4. Embedding Model → OpenSearch's `Embedding` input
5. OpenSearch → RAG Prompt → LLM → Chat Output

---

## Production Monitoring with RAG Analytics UI

The Next.js frontend provides a chat interface with built-in monitoring. Every interaction is evaluated for quality, categorized, and surfaced in analytics—with actionable insights through OpenSearch Dashboards.

### Key Monitoring Features

**Automatic Quality Analysis**
- Every answer evaluated by GPT-4o-mini (LLM-as-a-Judge)
- Quality scores (0-1) and labels (good/fair/poor)
- Flags for answers needing improvement with specific reasons

**Real-time Analytics Dashboard**
- Quality metrics and trends over time
- Question categorization (Technical, Business, Research, etc.)
- Latency monitoring and performance tracking
- Identify questions needing better answers

**OpenSearch Dashboards Integration**
- Pre-built visualizations for deep analysis
- Custom queries and aggregations on `rag_analytics` index
- Time-series analysis of quality trends
- Category and topic distribution charts

See the screenshot at the top of this README for an example of the analytics dashboard in action.

### Quick Start

```bash
cd frontend
npm install
cp env-example.txt .env.local
# Edit .env.local with:
# - watsonx.data OpenSearch credentials (URL, username, password)
# - OPENAI_API_KEY and LANGFLOW_FLOW_ID

npm run setup-opensearch  # Creates indices and dashboards
npm run dev               # Start the UI at http://localhost:3000
```

### Data Logged

Each interaction logs: question, answer, timestamp, latency, quality score (0-1), quality label (good/fair/poor), category, question type, and improvement suggestions.

View detailed analytics at your watsonx.data OpenSearch Dashboards URL (from `.env.local`).

See `frontend/README.md` for full documentation.

### How LLM Quality Scoring Works

Every time a user asks a question, the system uses a secondary LLM call (GPT-4o-mini) to evaluate the quality of the RAG answer. This is a technique called **LLM-as-a-Judge**, where we use one LLM to evaluate the output of another. The evaluation prompt is designed using several prompting best practices:

1. **Role Assignment**: The prompt tells the LLM it's analyzing a "RAG answer", giving it context about what kind of output it's evaluating
2. **Structured Input**: The question and answer are clearly labeled and separated, so the LLM knows exactly what to evaluate
3. **JSON Output Format**: We provide an exact JSON schema the LLM must follow, ensuring consistent, parseable responses
4. **Explicit Scoring Rubric**: The prompt includes clear criteria for each score range (Good/Fair/Poor), removing ambiguity
5. **Few-shot Examples via Criteria**: Rather than showing example outputs, the criteria descriptions act as implicit examples of what each score means

Here's a simplified view of what the evaluation prompt looks like:

```
Analyze the quality of this RAG answer.

QUESTION: {user's original question}
ANSWER: {the RAG system's response}

Respond with JSON containing:
- quality_score (0.0-1.0)
- quality_label (good/fair/poor)
- needs_improvement (true/false)
- improvement_reason (why, if needed)
- has_citations (does it reference sources?)
- confidence_expressed (appropriate uncertainty?)

Criteria:
- GOOD (0.7-1.0): Directly answers, accurate, cites sources
- FAIR (0.4-0.69): Partial answer, vague or missing details
- POOR (0-0.39): Wrong, off-topic, or unhelpful "I don't know"
```

This happens automatically in the background and doesn't affect the user's experience.

#### Quality Scoring

The LLM scores each answer from 0 to 1: **Good** (0.7+) means accurate and complete, **Fair** (0.4-0.69) means partial or vague, **Poor** (below 0.4) means incorrect or unhelpful. It also flags whether the answer cites sources and expresses appropriate confidence.

#### Question Categorization

Each question is classified by **category** (Technical, Business, Research, etc.), **type** (Factual, Procedural, Analytical, Comparative, etc.), and **complexity** (Simple, Moderate, Complex). This helps you see what users ask most and where your RAG needs improvement.

---

## Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| **RAG Analytics UI** | http://localhost:3000 | Chat interface with analytics |
| Langflow | From `.env` (`LANGFLOW_URL`, default port 7860) | Visual flow builder (no auth) |
| **OpenSearch (watsonx.data)** | `${OPENSEARCH_URL}` | Vector store API (from .env) |
| **OpenSearch Dashboards** | `${OPENSEARCH_DASHBOARDS_URL}` | Data exploration & RAG analytics (from .env) |

---

## OpenSearch Commands

Common commands for working with your watsonx.data OpenSearch instance:

```bash
# Verify OpenSearch is accessible
curl -u "${OPENSEARCH_USERNAME}:${OPENSEARCH_PASSWORD}" "${OPENSEARCH_URL}"

# List all indices
curl -u "${OPENSEARCH_USERNAME}:${OPENSEARCH_PASSWORD}" "${OPENSEARCH_URL}/_cat/indices?v"

# Count documents in hybrid_demo index
curl -u "${OPENSEARCH_USERNAME}:${OPENSEARCH_PASSWORD}" "${OPENSEARCH_URL}/hybrid_demo/_count"

# Check cluster health
curl -u "${OPENSEARCH_USERNAME}:${OPENSEARCH_PASSWORD}" "${OPENSEARCH_URL}/_cluster/health?pretty"
```

---

## OpenSearch Dev Tools Queries

Access Dev Tools at your watsonx.data OpenSearch Dashboards URL and try these queries:

```
# Browse documents
GET hybrid_demo/_search
{"size": 10, "_source": ["text", "metadata"], "query": {"match_all": {}}}

# Text search
GET hybrid_demo/_search
{"query": {"match": {"text": "hybrid search"}}}

# Check vectors exist
GET hybrid_demo/_search
{"size": 1, "_source": ["vector_field"], "query": {"exists": {"field": "vector_field"}}}

# Delete all documents (keeps index)
POST hybrid_demo/_delete_by_query
{"query": {"match_all": {}}}

# Delete index entirely
DELETE hybrid_demo
```

---

## LLM Configuration

### IBM watsonx.ai

Set these environment variables before starting Langflow:

```bash
export WATSONX_API_KEY="your-api-key"
export WATSONX_PROJECT_ID="your-project-id"
export WATSONX_URL="https://us-south.ml.cloud.ibm.com"
```

Recommended models:
- `ibm/granite-13b-chat-v2` for general Q&A
- `meta-llama/llama-3-70b-instruct` for complex reasoning

### OpenAI

```bash
export OPENAI_API_KEY="your-api-key"
```

---

## Tips

Start with a basic RAG flow before adding hybrid search complexity. Use OpenSearch Dashboards to verify documents are indexed correctly. Adjust chunk sizes based on your document types.

For hybrid search, use a fast LLM like gpt-4o-mini for keyword extraction since it runs on every query. Extract fewer keywords (1-3) for better precision.

---

## Resources

- [Langflow Documentation](https://docs.langflow.org/)
- [OpenSearch Documentation](https://opensearch.org/docs/latest/)
- [OpenSearch Hybrid Search](https://opensearch.org/docs/latest/search-plugins/hybrid-search/)
- [Unstructured.io Documentation](https://docs.unstructured.io/)
- [watsonx.ai Documentation](https://www.ibm.com/docs/en/watsonx-as-a-service)

---

## Next Steps: Dive into Analytics

Once you have the basic RAG pipeline running, explore the monitoring capabilities:

| Priority | Guide | What You'll Learn |
|----------|-------|-------------------|
| **Start Here** | [RAG Analytics Guide](docs/RAG-Analytics-Architecture.md) | Complete analytics architecture, how LLM-as-a-Judge works, quality scoring methodology |
| **Dashboards** | [OpenSearch Dashboards Guide](docs/OpenSearch-Dashboards-Guide.md) | Create custom visualizations, explore the `rag_analytics` index, build your own dashboards |
| **Production** | [One-Pager Architecture](docs/RAG-One-Pager-Architecture.md) | Concise reference for the complete system (includes PDF version) |

### What You Can Monitor

With this setup, you can answer questions like:
- "What percentage of answers are rated 'good' vs 'poor'?"
- "Which question categories have the lowest quality scores?"
- "What topics do users ask about most?"
- "Has quality improved since I added new documents?"
- "Which specific questions need better answers?"
- "What's my average response latency by category?"

All queryable through OpenSearch Dashboards or the built-in analytics UI.
