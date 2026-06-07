# Part 2: Add Features with IBM Bob

In this part, you'll use IBM Bob to add new features to the Vector Search application.

## Goals of This Part

- Learn how to use IBM Bob
- Give instructions in natural language to generate code
- Add 3 new features

## What is IBM Bob? (Review)

**IBM Bob** = A development tool where AI assists with coding

**What it can do**:

- Tell it in natural language "I want this feature"
- IBM Bob automatically writes the code
- It also explains the code

**Benefits**:

- Reduces coding effort
- Significantly shortens development time
- Generates high-quality code

## Features to Add

In this part, you'll add the following 3 features:

1. **Product image display**
2. **Price filter**
3. **Recommendation reason display**

??? note "About hot reload"
    The application has a hot reload feature, but in this hands-on, stop it once before changing code and start it again after the change to ensure the updates are applied.

??? note "Application file structure"
    - `app.py`: Defines the FastAPI API and screen
    - `common.py`: Handles `.env`, language selection, Milvus connection, and embedding model loading
    - `schema.py`: Defines the Milvus collection schema, index/search settings, and fields returned in search results
    - `insert_sample_data.py`: Inserts sample product data into Milvus
    - `sample_products.py`: Selects the sample product data based on `PARTICIPANT_LANGUAGE`
    - `sample_products_en.py`: Defines English sample data such as product names, descriptions, and prices

## Feature 1: Product Image Display {#feature-1-product-image-display}

!!! info "Why is this feature needed?"
    
    Current search results are text only. Having product images makes it visually clearer and improves user experience.

### Step 1: Open IBM Bob

Click the chat input field at the bottom of the IBM Bob screen

### Step 2: Switch to Code Mode

1. Click the "Mode" selector at the bottom right of the screen
2. Select "Code"

**Code mode** = Dedicated mode for writing code

??? note "Practice switching to Code mode"
    You can run this task while staying in **Vector Search Builder mode**.
    
    In this step, switch to **Code mode** intentionally to practice the basic mode-switching flow.

### Step 3: Stop the Application

Press ++ctrl+c++ in the terminal running the application to stop it.

### Step 4: Give Instructions to IBM Bob

Enter the following in the chat input field and press Enter:

```
Add an image_url field to the /search API JSON response.
Make it verifiable in Swagger UI.
```

**Key point**:

- Clearly communicate what you want to do

### Step 5: Wait for IBM Bob's Response

IBM Bob will automatically:

1. Understand the instruction
2. Find related files
3. Generate code
4. Display explanation

### Step 6: Review IBM Bob's Proposal

IBM Bob will make a proposal like the following.

Changes:

- **`sample_products_en.py`**: Add **`image_url`** to product data
- **`schema.py`**: Add **`image_url`** to the collection schema and search output fields
- **`insert_sample_data.py`**: Insert the new product field into Milvus
- **`app.py`**: Add **`image_url`** to the API response model and search result JSON

The exact proposal may vary, but for stored product fields, both the API response and the Milvus data schema need to stay aligned.

### Step 7: Approve Changes

1. Read IBM Bob's proposal
2. Click the "Approve" button
3. Changes are applied to the relevant files

### Step 8: Verify Operation

1. Reinsert sample data because the Milvus collection schema changed:

    ```bash
    python insert_sample_data.py
    ```

2. Start the application (execute **`python app.py`**. [:material-play-circle: How to start](part1.md#app-restart))
3. Open Swagger UI (**`http://localhost:8002/docs`**)
4. Execute search:

    ```json
    {
      "query": "red sneakers"
    }
    ```

5. Verify results:

    ```json
    {
      "results": [
        {
          "product_name": "Red Sports Shoes",
          "image_url": "https://example.com/images/red-shoes.jpg",
          "similarity_score": 0.5474,
          "price": 7500
        }
      ]
    }
    ```

**Verification point**: **`image_url`** field has been added

### Feature 1 Completion Check

- [ ] Gave instructions to IBM Bob
- [ ] IBM Bob generated code
- [ ] Approved changes
- [ ] Reinserted sample data after the schema change
- [ ] **`image_url`** is displayed in search results

## Feature 2: Price Filter

!!! info "Why is this feature needed?"
    
    Being able to filter by price range allows finding products within budget.

### Step 1: Stop the Application

Press ++ctrl+c++ in the terminal running the application to stop it.

### Step 2: Give Instructions to IBM Bob

Enter the following in the chat input field and press Enter:

```text
Allow min_price and max_price to be specified in the /search API JSON request.
Return only search results within the specified price range.
```

### Step 3: Review IBM Bob's Proposal

IBM Bob will make a proposal like the following.

Changes:

- **`app.py`**: Add **`min_price`** and **`max_price`** parameters to the search request
- Filter search results by price range

Price is already stored in the existing Milvus collection, so this feature usually does not require changing `schema.py` or reinserting sample data.

### Step 4: Approve Changes

Click the "Approve" button

### Step 5: Verify Operation

1. Start the application (execute **`python app.py`**. [:material-play-circle: How to start](part1.md#app-restart))
2. Execute search:

    ```json
    {
      "query": "sneakers",
      "min_price": 5000,
      "max_price": 10000
    }
    ```

3. Verify results: Only products between 5000 and 10000 yen are displayed

### Feature 2 Completion Check

- [ ] Gave instructions to IBM Bob
- [ ] Approved changes
- [ ] Price filter works

## Feature 3: Recommendation Reason Display

!!! info "Why is this feature needed?"
    
    Displaying why a product is recommended increases user confidence.

### Step 1: Stop the Application

Press ++ctrl+c++ in the terminal running the application to stop it.

### Step 2: Give Instructions to IBM Bob

Enter the following in the chat input field and press Enter:

```text
Add a recommendation_reason field to the /search API JSON response.
Generate the reason text based on similarity scores.
```

### Step 3: Review IBM Bob's Proposal

IBM Bob will make a proposal like the following.

Changes:

- **`app.py`**: Add **`recommendation_reason`** to the API response model and search result JSON
- Generate reasons based on similarity scores

The recommendation reason is generated from the search score, so this feature usually does not require changing stored product data.

### Step 4: Approve Changes

Click the "Approve" button

### Step 5: Verify Operation

1. Start the application (execute **`python app.py`**. [:material-play-circle: How to start](part1.md#app-restart))
2. Execute search:

    ```json
    {
      "query": "beginner camera"
    }
    ```

3. Verify results:

    ```json
    {
      "results": [
        {
          "product_name": "Entry-level Digital Camera",
          "similarity_score": 0.6123,
          "recommendation_reason": "Related to the search content (similarity: 0.6123)"
        }
      ]
    }
    ```

### Feature 3 Completion Check

- [ ] Gave instructions to IBM Bob
- [ ] Approved changes
- [ ] Recommendation reason is displayed

## Part 2 Completion Check

- [ ] Added product image display feature
- [ ] Added price filter feature
- [ ] Added recommendation reason display feature
- [ ] All features work correctly

## FAQ

??? question "Q1: IBM Bob is not responding"

    Solution:
    
    1. Check internet connection
    2. Restart IBM Bob

??? question "Q2: Changes are not reflected"

    Solution:
    
    1. Verify file is saved
    2. Restart the application manually
    
        1. Press ++ctrl+c++ in the terminal running the application (stop)
        2. Execute **`python app.py`** ([:material-play-circle: How to start](part1.md#app-restart))
    3. Reload browser

??? question "Q3: Error is displayed"

    Solution:
    
    1. Copy error message
    2. Enter the following in IBM Bob's chat screen:
        
        ```text
        Fix this error
        ```

## Next Steps

Once Part 2 is complete, proceed to [Part 3: Verification](part3.md)!
