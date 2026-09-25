# Welcome to Vector Search Hands-on

In this hands-on workshop, you will combine **Building Blocks** and **IBM Bob** to experience AI-driven development for building a "semantic search" feature (Vector Search).

!!! info "Prerequisites"
    
    IBM Bob is already installed and available for use.
    This hands-on was verified with **IBM Bob 2.2.0** (September 2026). Other versions may show different modes, approval prompts, or proposals.

## What You'll Experience in This Hands-on

### Value of Building Blocks + IBM Bob

This hands-on workshop demonstrates how combining **Building Blocks** (pre-built technical components) with **IBM Bob** (an AI development assistant) can complete development that would typically take days to weeks in **approximately 60 minutes**.

**Without Building Blocks (Time required: days to weeks):**

![Development flow without Building Blocks](images/without-building-blocks-en.svg)

Without Building Blocks, the following work is required:

- Vector database selection and learning
- Embedding model selection and integration
- API design and implementation
- Error handling
- Performance tuning

**With Building Blocks + IBM Bob (This hands-on, Time required: approximately 60 minutes):**

![Development flow with Building Blocks + IBM Bob](images/with-building-blocks-en.svg)

Responsibilities for each process:

- **Building Blocks**:
    - Technology selection (Milvus, embedding models)
    - Environment setup support (Vector Search Builder mode, API samples)
- **IBM Bob**:
    - Requirements definition
    - Coding
    - Testing
    - Debugging

??? note "About IBM Bob's Coverage"
    IBM Bob can support the whole software development lifecycle, from requirements definition to debugging. In this hands-on, Building Blocks and the instructor's Milvus environment take care of technology selection and setup, so IBM Bob focuses on coding, testing, and debugging.

## What are Building Blocks?

**Building Blocks** are **pre-built technical components** leveraging IBM's technology stack. Using Building Blocks accelerates solution development.

### Features of Building Blocks

- **Ready to use**: Start using immediately without complex configuration or learning
- **Best practices**: Optimal implementation patterns designed by IBM's engineering team
- **Domain-specific**: Provides Vector Search-specific guidance and implementation patterns
- **Customizable**: Flexibly extend to meet business requirements using IBM Bob

### Building Block Used in This Hands-on

**Vector Search Builder** (Milvus-based)

**What it provides**: Vector database (Milvus) construction and management capabilities

**Included features**:

- Milvus database setup
- Collection (data container) creation
- Local embedding model integration with Hugging Face Transformers
- Sample product data ingestion workflow
- Vector search optimization

**Integration with IBM Bob**: Using Vector Search Builder mode, IBM Bob provides specialized support for Vector Search

!!! example "Value of Building Blocks"
    
    **Without Building Blocks**: Read Milvus documentation, learn Python SDK, select and integrate embedding models (days)

    **With Building Blocks**: Install Vector Search Builder and instruct IBM Bob (minutes)

??? info "Unique Innovations in This Hands-on"
    Paths are relative to the [mukoubuchi/vector-search-hands-on](https://github.com/mukoubuchi/vector-search-hands-on) repository.

    - **Shared Milvus**: The instructor runs Milvus for everyone (`setup/instructor/docker-compose.yml`), so participants need only IBM Bob, the participant zip, and the connection information
    - **On-site or remote**: The documentation is shared on the local network (`http://instructor IP:8001`) or through GitHub Pages or ngrok
    - **No API key**: Hugging Face Transformers creates the embeddings locally
    - **Step by step**: Part 1 tries Vector Search, Part 2 adds features with IBM Bob, and Part 3 checks them and cleans up

    | Provider | What's Provided | Purpose |
    |:---|:---|:---|
    | **Building Blocks** | Vector Search Builder mode<br/>FastAPI sample<br/>Milvus setup guide | Technology foundation provision<br/>Development acceleration |
    | **This Hands-on** | Instructor environment (Docker Compose)<br/>Participant scripts<br/>Educational documentation | Educational design<br/>Learning experience optimization |

## What is IBM Bob?

**IBM Bob** is a development tool where AI assists with coding.

### What IBM Bob Can Do

- **Natural language instructions**: Communicate what you want to do in words
- **Automatic code generation**: Automatically writes high-quality code
- **Code review**: Points out code issues
- **Integration with Building Blocks**: Provides technology-specific support through custom modes

### Synergy with Building Blocks

Building Blocks provides the foundation right away and IBM Bob customizes it from natural language instructions, so you reach production-level quality in the shortest time.

### Comparison of Development Methods

| Development Method | Time Required | Required Skills | Code Quality |
|:---|---:|:---|:---|
| **Without Building Blocks** | Days to weeks | Programming, DB design, API design | Depends on developer skills |
| **IBM Bob only** | Hours to days | Basic technical understanding | High quality but time-consuming to build |
| **Building Blocks + IBM Bob** | Minutes to hours | Just need to instruct in natural language | Production-level high quality |

## What is Vector Search?

**Vector Search** is a technology that searches by understanding the "meaning" of words.

### Difference from Traditional Search

**Traditional keyword search**:

- "red sneakers" → Searches for products containing the **characters** "red" and "sneakers"
- "red running shoes" won't be found (different characters)

**Vector Search (semantic search)**:

- "red sneakers" → Understands the **meaning** of "red" and "sneakers"
- "red running shoes" will be found (similar meaning)
- "beginner camera" → "entry-level digital camera" will be found

### Real-world Use Cases

- **E-commerce sites**: "Find similar products" feature
- **Internal search**: "Find documents similar to this document"
- **Customer support**: "Find similar questions"

## Hands-on Flow

**Total**: Approximately 60 minutes

| Part | Content | Time Required |
|:---|:---|---:|
| [Preparation](preparation.md) | Vector Search Builder setup | 10 minutes |
| [Part 1](part1.md) | Experience Vector Search | 15 minutes |
| [Part 2](part2.md) | Add features with IBM Bob | 25 minutes |
| [Part 3](part3.md) | Verification and cleanup | 5 minutes |
| [Summary](summary.md) | Review and Q&A | 5 minutes |

## Requirements

- **Computer** (Mac, Windows) and internet connection
- **IBM Bob** (already installed)
- **Web browser** (Chrome, Firefox, Safari, Edge, etc.)

**Distributed by instructor**:

- Hands-on procedure URL
- Minimal Vector Search Builder participant package (`vector-search-builder-en.zip`)
- Connection information (Milvus connection information)

[Next →](preparation.md){ .workshop-next }
