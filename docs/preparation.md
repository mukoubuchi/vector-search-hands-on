# Preparation

Let's start with the preparation for the hands-on.

First, please check how to open the terminal/command prompt.

!!! tip "How to Open Terminal/Command Prompt"
    
    **Open Terminal/Command Prompt in IBM Bob**:
    
    You can open it using one of the following methods:
    
    - From the menu bar: <kbd>Terminal</kbd> → <kbd>New Terminal</kbd>
    - <kbd>Ctrl</kbd> + <kbd>`</kbd> (backtick)
    - Click the icon in the upper right, or <kbd>Cmd</kbd> + <kbd>J</kbd> (toggle panel)
    
    A black screen (terminal/command prompt) will appear at the bottom of the screen.
    
    ---
    
    **Open System Terminal/Command Prompt**:
    
    === ":fontawesome-brands-apple: Mac"
        1. Open Spotlight with <kbd>Cmd</kbd> + <kbd>Space</kbd>
        2. Type "Terminal"
        3. Press <kbd>Enter</kbd>
        
        **Or**:
        
        - Applications → Utilities → Terminal
    
    === ":fontawesome-brands-windows: Windows"
        1. Press <kbd>Win</kbd> + <kbd>R</kbd>
        2. Type "cmd"
        3. Press <kbd>Enter</kbd>
        
        **Or**:
        
        - Start menu → Search for "Command Prompt"

## Requirements

### 1. Vector Search Builder Mode

**Vector Search Builder** is a custom mode for IBM Bob provided as part of Building Blocks, making it easy to build vector search functionality.

#### Vector Search Builder as a Building Block

**Provider**: IBM Build Engineering Team

**Included features**:

- Milvus database setup and management
- Embedding model integration (watsonx, HuggingFace, local)
- Data ingestion pipeline construction
- Vector search optimization
- IBM Cloud Object Storage integration

**Integration with IBM Bob**:

- AI assistant specialized for Vector Search
- Code generation with understanding of Building Blocks features
- Implementation support based on best practices

!!! info "Benefits of Building Blocks"
    
    **Normal development**: Read Milvus documentation, learn SDK, write code from scratch (days)

    **Using Building Blocks**: Install Vector Search Builder and instruct IBM Bob in natural language (minutes)

    **Innovation in this hands-on**: Instructor provides Milvus environment, participants join with only IBM Bob (no environment setup required)

#### Step 1: Install Vector Search Builder (Building Block)

1. Copy the distributed **`vector-search-builder.zip`** to your desktop

2. Extract the zip file

    === ":fontawesome-brands-apple: Mac"
        **GUI**: Double-click
        
        **Terminal/Command Prompt**:
        ```bash
        cd ~/Desktop
        unzip vector-search-builder.zip
        ```

    === ":fontawesome-brands-windows: Windows"
        **GUI**: Right-click → "Extract All"

        ※ Simply opening by double-clicking does not extract, so please execute "Extract All"
        
        **Terminal/Command Prompt**:
        ```bash
        cd %USERPROFILE%\Desktop
        tar -xf vector-search-builder.zip
        ```

3. Confirm that a **`vector-search-builder`** folder is created with a **`.bob`** folder inside

!!! warning "Important"
    
    The `.bob` folder must be placed directly under the project folder (in this hands-on, `vector-search-builder`).

??? info "Contents of vector-search-builder.zip"
    **`vector-search-builder.zip`** contains:

    **Building Blocks**:

    - **`.bob/`**: Vector Search Builder mode definition

    **Added in this hands-on**:

    - **`setup/instructor/`**: Instructor Milvus environment (Docker Compose)
    - **`setup/participant/`**: Participant connection test scripts
    - **`.env.example`**: Connection information configuration template
    - **`docs/`**: Hands-on documentation

??? tip "Building Blocks Installation Methods"
    Normally, Building Blocks are installed using the following methods:

    - **Global installation**: `~/.config/IBM Bob/User/globalStorage/ibm.bob-code/`
    - **Project local**: `.bob/` (this hands-on's method)

    In this hands-on, installing locally to the project keeps the environment clean and allows easy cleanup.

#### Step 2: Open the `vector-search-builder` Folder in IBM Bob

1. Launch IBM Bob

2. Open the `vector-search-builder` folder

    === ":fontawesome-brands-apple: Mac"
        **GUI**: <kbd>File</kbd> → <kbd>Open...</kbd> and select the `vector-search-builder` folder, or press <kbd>⌘</kbd> + <kbd>O</kbd> to open the folder selection dialog.

    === ":fontawesome-brands-windows: Windows"
        **GUI**: <kbd>File</kbd> → <kbd>Open...</kbd> and select the `vector-search-builder` folder, or press <kbd>Ctrl</kbd> + <kbd>O</kbd> to open the folder selection dialog.

3. Confirm that "Vector Search Builder" appears in the "Mode" selector at the bottom right of the screen and select it

!!! success "Recognition of Building Blocks Dedicated Custom Mode"
    
    IBM Bob detects the `.bob/` folder and automatically loads the Building Blocks dedicated custom mode (Vector Search Builder mode in this hands-on).

    This mode enables IBM Bob to understand:

    - How to operate Milvus database
    - Vector search best practices
    - Embedding model integration methods
    - Building Blocks features and constraints

### 2. Connection Information

#### Milvus (Vector Database)

Configure the IP address distributed by the instructor.

!!! example "Configuring Connection Information"
    
    1. Open the **`setup/participant`** folder
    
    2. Copy **`.env.example`** and rename the copied file to **`.env`**
        
        === ":fontawesome-brands-apple: Mac"
            **GUI**: Right-click `.env.example` in Finder → "Duplicate" → Rename to `.env`
            
            **Terminal/Command Prompt**:
            ```bash
            cd setup/participant
            cp .env.example .env
            ```

        === ":fontawesome-brands-windows: Windows"
            **GUI**: Right-click `.env.example` in Explorer → "Copy" → "Paste" → Rename to `.env`
            
            **Terminal/Command Prompt**:
            ```bash
            cd setup\participant
            copy .env.example .env
            ```

    3. Open the **`.env`** file and enter the IP address distributed by the instructor in **`MILVUS_HOST`**
       
        #### MILVUS_HOST Configuration {#milvus_host}
       
        ```properties
        # Milvus connection information
        MILVUS_HOST=192.168.1.100  # ← Change to IP address distributed by instructor
        
        # No changes needed below
        MILVUS_PORT=19530
        MILVUS_USER=root
        MILVUS_PASSWORD=Milvus
        EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
        EMBEDDING_DIMENSION=384
        COLLECTION_NAME=knowledge_base
        ```

    4. Save the file
    
        === ":fontawesome-brands-apple: Mac"
            <kbd>Cmd</kbd> + <kbd>S</kbd>

        === ":fontawesome-brands-windows: Windows"
            <kbd>Ctrl</kbd> + <kbd>S</kbd>


#### Embedding Model (AI that Converts Text to Numbers)

Uses Hugging Face Transformers (no API key required, free).

**What is an embedding model**: An AI model that converts the "meaning" of text into numbers (vectors).

- Model: **`paraphrase-multilingual-MiniLM-L12-v2`**
- Dimensions: **384** (represents meaning with 384 numbers)
- Features: Multilingual support

### 3. Python Environment Setup

#### Step 1: Verify Python Installation

First, verify that Python is installed.

=== ":fontawesome-brands-apple: Mac"
    **Terminal/Command Prompt**:
    ```bash
    python3 --version
    ```

=== ":fontawesome-brands-windows: Windows"
    **Terminal/Command Prompt**:
    ```bash
    python --version
    ```

**Expected output**:

```
Python 3.8.x or higher
```

!!! warning "If Python is Not Installed"
    
    If Python 3.8 or higher is not installed, please install from:
    
    **Official site**: [https://www.python.org/downloads/](https://www.python.org/downloads/)
    
    === ":fontawesome-brands-apple: Mac"
        If using Homebrew:
        ```bash
        brew install python3
        ```
    
    === ":fontawesome-brands-windows: Windows"
        You can also install from the Microsoft Store.

#### Step 2: Create Virtual Environment (Important)

!!! danger "To Avoid Breaking the Global Environment"
    
    **Always use a virtual environment**. Installing directly in the global environment may affect other projects.

Create a virtual environment and install packages within it.

=== ":fontawesome-brands-apple: Mac"
    **Terminal/Command Prompt**:
    ```bash
    cd ~/Desktop/vector-search-builder/setup/participant
    python3 -m venv venv
    source venv/bin/activate
    ```

=== ":fontawesome-brands-windows: Windows"
    **Terminal/Command Prompt**:
    ```bash
    cd %USERPROFILE%\Desktop\vector-search-builder\setup\participant
    python -m venv venv
    venv\Scripts\activate
    ```

**When the virtual environment is activated**, `(venv)` will appear at the beginning of the prompt:

```bash
(venv) user@computer:~/Desktop/vector-search-builder/setup/participant$
```

!!! success "Benefits of Virtual Environment"
    
    - **Isolation**: Environment dedicated to this project
    - **Safety**: Does not break the global environment
    - **Cleanup**: Can be completely removed by just deleting the `venv` folder
    - **Reproducibility**: Can reproduce the same configuration in other environments

#### Step 3: Install Required Packages

With the virtual environment activated, install Python packages.

!!! example "Request IBM Bob to Install Packages"
    
    1. **Verify the virtual environment is activated** (`(venv)` is displayed in the prompt)
    
    2. Enter the following in IBM Bob's chat input:
    
        ```text
        Install all packages listed in setup/participant/requirements.txt
        ```
    
    3. Wait for installation to complete (may take several minutes)

??? info "Packages to be Installed"
    The following packages will be installed (70+ packages, all version-locked):
    
    **Main packages**:
    - **pymilvus**: Milvus database client
    - **sentence-transformers**: Embedding models
    - **torch**: Machine learning framework
    - **fastapi**: Web framework
    - **pandas**: Data processing
    - **langchain**: Text processing
    - **python-dotenv**: Environment variable management
    
    **All dependencies are also locked**:
    - transformers, huggingface-hub, tokenizers
    - pydantic, uvicorn, starlette
    - numpy, scipy, scikit-learn
    - Many others

??? tip "If Installing Manually"
    If installing manually without using IBM Bob, execute the following in the terminal:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder/setup/participant
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        cd %USERPROFILE%\Desktop\vector-search-builder\setup\participant
        python -m venv venv
        venv\Scripts\activate
        pip install -r requirements.txt
        ```

??? warning "Deactivating Virtual Environment"
    When finished working, you can deactivate the virtual environment:
    
    ```bash
    deactivate
    ```
    
    Next time you work, activate it again:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder/setup/participant
        source venv/bin/activate
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        cd %USERPROFILE%\Desktop\vector-search-builder\setup\participant
        venv\Scripts\activate
        ```

## Preparation Completion Checklist

- [ ] IBM Bob is installed and available
- [ ] Python 3.8 or higher is installed
- [ ] Extracted **`vector-search-builder.zip`**
- [ ] **`.bob`** folder exists
- [ ] Opened `vector-search-builder` folder in IBM Bob
- [ ] "Vector Search Builder" mode is displayed
- [ ] Entered connection information in **`setup/participant/.env`** file
- [ ] **Created and activated virtual environment** (`(venv)` is displayed in prompt)
- [ ] Installed Python packages in virtual environment

## FAQ

??? question "Q1: Vector Search Builder mode is not displayed"

    Solution:
    
    1. Verify **`.bob`** folder exists
    2. Reload IBM Bob (:fontawesome-brands-apple: <kbd>⌘</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> / :fontawesome-brands-windows: <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> → "Reload Window")
    3. Reopen the project folder

??? question "Q2: Don't know where to enter connection information"

    Solution:
    
    1. Open the **`setup/participant`** folder in the project folder
    2. Look for the **`.env`** file (if not found, copy **`.env.example`**)


## Next Steps

Once preparation is complete, proceed to [Part 1: Environment Verification and Demo](part1.md)!