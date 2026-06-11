# Preparation

Let's start with the preparation for the hands-on.

First, please check how to open the terminal/command prompt.

!!! tip "How to Open Terminal/Command Prompt"
    
    In the following steps, use either IBM Bob's built-in terminal or your system terminal/command prompt.

**Open Terminal/Command Prompt in IBM Bob**:

You can open it using one of the following methods:

- From the menu bar: <kbd>Terminal</kbd> → <kbd>New Terminal</kbd>
- <kbd>Ctrl</kbd> + <kbd>`</kbd> (backtick)
- Click the icon in the upper right, or <kbd>Cmd</kbd> + <kbd>J</kbd> (toggle panel)

A black screen (terminal/command prompt) will appear at the bottom of the screen.

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

#### Vector Search Builder Overview

**Provider**: IBM Build Engineering Team

**Included features**:

- Milvus database setup and management
- Local embedding model integration with Hugging Face Transformers
- Data ingestion pipeline construction
- Vector search optimization
- Sample product data ingestion workflow

**Integration with IBM Bob**:

- AI assistant specialized for Vector Search
- Code generation with understanding of Building Blocks features
- Implementation support based on best practices

!!! info "Benefits of Building Blocks"
    
    **Normal development**: Read Milvus documentation, learn SDK, write code from scratch (days)

    **Using Building Blocks**: Install Vector Search Builder and instruct IBM Bob in natural language (minutes)

    **Innovation in this hands-on**: Instructor provides Milvus environment, participants join with only IBM Bob (no environment setup required)

#### Step 1: Install Vector Search Builder

1. Copy the distributed **`vector-search-builder-en.zip`** to your desktop

2. Extract the zip file

    === ":fontawesome-brands-apple: Mac"
        **GUI**: Double-click
        
        **Terminal/Command Prompt**:
        ```bash
        cd ~/Desktop
        mkdir -p vector-search-builder-en
        unzip vector-search-builder-en.zip -d vector-search-builder-en
        ```

    === ":fontawesome-brands-windows: Windows"
        **GUI**: Right-click → "Extract All"

        ※ Simply opening by double-clicking does not extract, so please execute "Extract All"
        
        **Terminal/Command Prompt**:
        ```bash
        cd %USERPROFILE%\Desktop
        mkdir vector-search-builder-en
        tar -xf vector-search-builder-en.zip -C vector-search-builder-en
        ```

3. Confirm that a **`vector-search-builder-en`** folder is created with a **`.bob`** folder inside

!!! warning "Important"
    
    The `.bob` folder must be placed directly under the project folder (in this hands-on, `vector-search-builder-en`).

??? info "Contents of vector-search-builder-en.zip"
    **`vector-search-builder-en.zip`** contains:

    **Building Blocks**:

    - **`.bob/`**: Vector Search Builder mode definition

    **Participant setup files**:

    - **`setup/participant/`**: Participant scripts, FastAPI demo app, and language-specific sample data
    - **`setup/participant/.env.example`**: Connection information configuration template
    - **`setup/participant/sample_products.py`**: Selects the sample product data to use
    - **`setup/participant/sample_products_en.py`**: English sample product data
    - **`PARTICIPANT_LANGUAGE=en`**: English sample product data and runtime messages are used

??? tip "Building Blocks Installation Methods"
    Normally, Building Blocks are installed using the following methods:

    - **Global installation**: `~/.config/IBM Bob/User/globalStorage/ibm.bob-code/`
    - **Project local**: `.bob/` (this hands-on's method)

    In this hands-on, installing locally to the project keeps the environment clean and allows easy cleanup.

#### Step 2: Open the `vector-search-builder-en` Folder in IBM Bob

!!! info "IBM Bob Version Used"
    
    This hands-on uses **IBM Bob 1.0.3**.
    If you use a different version, some screens or command behavior may differ.

1. Launch IBM Bob

2. Open the `vector-search-builder-en` folder

    === ":fontawesome-brands-apple: Mac"
        **GUI**: <kbd>File</kbd> → <kbd>Open...</kbd> and select the `vector-search-builder-en` folder, or press <kbd>⌘</kbd> + <kbd>O</kbd> to open the folder selection dialog.

    === ":fontawesome-brands-windows: Windows"
        **GUI**: <kbd>File</kbd> → <kbd>Open...</kbd> and select the `vector-search-builder-en` folder, or press <kbd>Ctrl</kbd> + <kbd>O</kbd> to open the folder selection dialog.

3. Confirm that "Vector Search Builder" appears in the "Mode" selector at the bottom right of the screen and select it

!!! success "Vector Search Builder Mode"
    
    When you select Vector Search Builder mode from the "Mode" selector, the Building Blocks dedicated custom mode becomes active.

    This mode enables IBM Bob to understand:

    - How to operate Milvus database
    - Vector search best practices
    - Embedding model integration methods
    - Building Blocks features and constraints

### 2. Connection Information

#### Milvus (Vector Database)

Configure the IP address distributed by the instructor.

!!! example "Practice: Configure connection information"
    
    Create the configuration file for connecting to Milvus, then enter the IP address distributed by the instructor.

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

3. Open the **`.env`** file and enter the connection information distributed by the instructor

    #### Milvus Connection Settings {#milvus_host}

    === "On-site (same network)"

        ```properties
        # Milvus connection information
        MILVUS_HOST=192.168.1.100  # ← Change to IP address distributed by instructor
        
        # Collection name (Milvus is shared by all participants)
        COLLECTION_NAME=products_taro  # ← Change to a name unique to you
        
        # No changes needed below
        MILVUS_PORT=19530
        MILVUS_USER=root
        MILVUS_PASSWORD=Milvus
        EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
        PARTICIPANT_LANGUAGE=en
        ```

    === "Remote (ngrok)"

        ```properties
        # Milvus connection information
        MILVUS_HOST=0.tcp.jp.ngrok.io  # ← Change to hostname distributed by instructor
        MILVUS_PORT=24051              # ← Change to port number distributed by instructor
        
        # Collection name (Milvus is shared by all participants)
        COLLECTION_NAME=products_taro  # ← Change to a name unique to you
        
        # No need to change below
        MILVUS_USER=root
        MILVUS_PASSWORD=Milvus
        EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
        PARTICIPANT_LANGUAGE=en
        ```

    !!! warning "Set a unique collection name"
        
        All participants connect to the same Milvus server managed by the instructor.
        Set **`COLLECTION_NAME`** to a name that is unique to you (e.g. **`products_taro`**, using letters, numbers, and underscores).
        If two participants use the same name, inserting sample data will overwrite each other's collection.

    !!! warning "ngrok Connection Note"
        
        When using ngrok, a corporate VPN or DNS security product such as Cisco Umbrella may block access to the ngrok TCP tunnel or prevent the hostname from resolving correctly.
        Even after disconnecting the VPN, the connection may still fail if Cisco Umbrella or a similar security product remains active.
        If you cannot connect, follow your organization's rules and use an alternative method provided by the instructor, such as connecting from the same network.

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

If Python 3.8 or higher is not installed, install it before continuing.

=== ":fontawesome-brands-apple: Mac"
    Download and install the installer from the official site.

    **Official site**: [https://www.python.org/downloads/](https://www.python.org/downloads/)

    If you use Homebrew, you can also install with:

    ```bash
    brew install python3
    ```

=== ":fontawesome-brands-windows: Windows"
    Download and run the installer from the official site.

    **Official site**: [https://www.python.org/downloads/](https://www.python.org/downloads/)

    !!! warning "Installation Note"
        On the first installer screen, check **Add python.exe to PATH** before clicking **Install Now**. Without this option, `python` and `pip` may not run from Command Prompt.

#### Step 2: Create Virtual Environment (Important)

!!! danger "To Avoid Breaking the Global Environment"
    
    **Always use a virtual environment**. Installing directly in the global environment may affect other projects.

Create a virtual environment and install packages within it.

=== ":fontawesome-brands-apple: Mac"
    **Terminal/Command Prompt**:
    ```bash
    cd ~/Desktop/vector-search-builder-en/setup/participant
    python3 -m venv venv
    source venv/bin/activate
    ```

=== ":fontawesome-brands-windows: Windows"
    **Terminal/Command Prompt**:
    ```bash
    cd %USERPROFILE%\Desktop\vector-search-builder-en\setup\participant
    python -m venv venv
    venv\Scripts\activate
    ```

!!! note "About Prompt Display"

    When the virtual environment is activated, `(venv)` may appear at the beginning of the prompt depending on your environment. It may not appear depending on your terminal or shell settings.

!!! success "Benefits of Virtual Environment"
    
    - **Isolation**: Environment dedicated to this project
    - **Safety**: Does not break the global environment
    - **Cleanup**: Can be completely removed by just deleting the `venv` folder
    - **Reproducibility**: Can reproduce the same configuration in other environments

#### Step 3: Install Required Packages {#install-packages}

Directly specify the Python executable inside `venv` to install Python packages.

1. **Verify that the `venv` folder has been created**

2. Run the following in the terminal:

    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder-en/setup/participant
        venv/bin/python -m pip install -r requirements.txt
        ```

    === ":fontawesome-brands-windows: Windows"
        ```cmd
        cd %USERPROFILE%\Desktop\vector-search-builder-en\setup\participant
        venv\Scripts\python -m pip install -r requirements.txt
        ```

3. Wait for installation to complete (may take several minutes)

??? note "Why directly specify Python inside venv"

    Even if you activated the virtual environment in your terminal, another terminal or AI tool may not inherit that state. Specifying `venv/bin/python` or `venv\Scripts\python` directly ensures the packages are installed into `venv`.

??? info "Packages to be Installed"
    The following packages will be installed:
    
    **Main packages**:

    - **pymilvus**: Milvus database client
    - **sentence-transformers**: Embedding models
    - **torch**: Machine learning framework
    - **fastapi**: Web framework
    - **uvicorn**: ASGI server
    - **python-dotenv**: Environment variable management
    
    **Dependencies (auto-installed)**:

    - transformers, huggingface-hub
    - pydantic, starlette
    - scikit-learn, marshmallow
    - And others

??? warning "Deactivating Virtual Environment"
    When finished working, you can deactivate the virtual environment:
    
    ```bash
    deactivate
    ```
    
    Next time you work, activate it again:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder-en/setup/participant
        source venv/bin/activate
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        cd %USERPROFILE%\Desktop\vector-search-builder-en\setup\participant
        venv\Scripts\activate
        ```

## Preparation Completion Checklist

- [ ] IBM Bob is installed and available
- [ ] Python 3.8 or higher is installed
- [ ] Extracted **`vector-search-builder-en.zip`**
- [ ] **`.bob`** folder exists
- [ ] Opened `vector-search-builder-en` folder in IBM Bob
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
