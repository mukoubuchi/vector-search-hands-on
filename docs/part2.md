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

## Feature 1: Product Image Display

!!! info "Why is this feature needed?"
    
    Current search results are text only. Having product images makes it visually clearer and improves user experience.

### Step 1: Open IBM Bob

Click the chat input field at the bottom of the IBM Bob screen

### Step 2: Switch to Code Mode

1. Click the "Mode" selector at the bottom right of the screen
2. Select "Code"

**Code mode** = Dedicated mode for writing code

??? note "Can also be executed in other modes"
    This task can also be executed in the following modes:
    
    - **Advanced mode**: Code editing + additional tools (MCP, Browser)
    - **Vector Search Builder mode**: Vector Search specialized (used in this hands-on)
    
    By selecting Code mode, you can learn the basic operation of mode switching.

### Step 3: Give Instructions to IBM Bob

Enter the following in the chat input field and press Enter:

```
Display product images in search results
```

**Key point**:

- Clearly communicate what you want to do

### Step 4: Wait for IBM Bob's Response

IBM Bob will automatically:

1. Understand the instruction
2. Find related files
3. Generate code
4. Display explanation

### Step 5: Review IBM Bob's Proposal

IBM Bob will make a proposal like the following.

Changes:

- **`app.py`**: Add **`image_url`** field to response
- Retrieve image URL from product data
- Include image URL in search results

### Step 6: Approve Changes

1. Read IBM Bob's proposal
2. Click the "Approve" button
3. Changes are applied to the file

### Step 7: Verify Operation

1. Open Swagger UI (**`http://localhost:8002/docs`**)
2. Restart the application

    Enter the following in IBM Bob's chat screen:
    
    ```text
    Restart the demo application
    ```
    
    ??? tip "If restarting manually"
        1. Press ++ctrl+c++ in the terminal (stop)
            
            **Note**: If you started via IBM Bob, you cannot access the terminal that Bob operates, so this stop operation is not possible.
        
        2. Execute **`python app.py`** ([:material-play-circle: How to start](../part1/#app-restart))
3. Execute search:

   ```json
   {
     "query": "red sneakers"
   }
   ```

4. Verify results:

   ```json
   {
     "results": [
       {
         "product_name": "Red Running Shoes",
         "image_url": "https://example.com/images/red-shoes.jpg",
         "similarity_score": 0.92,
         "price": 8900
       }
     ]
   }
   ```

**Verification point**: **`image_url`** field has been added

### Feature 1 Completion Check

- [ ] Gave instructions to IBM Bob
- [ ] IBM Bob generated code
- [ ] Approved changes
- [ ] **`image_url`** is displayed in search results

## Feature 2: Price Filter

### Why is this feature needed?

Being able to filter by price range allows finding products within budget.

### Step 1: Give Instructions to IBM Bob

Enter the following in the chat input field and press Enter:

```text
Add a feature to filter by price range.
Allow specifying minimum and maximum prices.
```

### Step 2: Review IBM Bob's Proposal

IBM Bob will make a proposal like the following.

Changes:

- **`app.py`**: Add **`min_price`** and **`max_price`** parameters
- Filter search results by price range

### Step 3: Approve Changes

Click the "Approve" button

### Step 4: Verify Operation

1. Restart the application

    Enter the following in IBM Bob's chat screen:
    
    ```text
    Restart the demo application
    ```
    
    ??? tip "If restarting manually"
        1. Press ++ctrl+c++ in the terminal (stop)
            
            **Note**: If you started via IBM Bob, you cannot access the terminal that Bob operates, so this stop operation is not possible.
        
        2. Execute **`python app.py`** ([:material-play-circle: How to start](../part1/#app-restart))
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

### Why is this feature needed?

Displaying why a product is recommended increases user confidence.

### Step 1: Give Instructions to IBM Bob

Enter the following in the chat input field and press Enter:

```text
Display "why this product is recommended" in search results.
Generate reasons based on similarity scores.
```

### Step 2: Review IBM Bob's Proposal

IBM Bob will make a proposal like the following.

Changes:

- **`app.py`**: Add **`recommendation_reason`** field
- Generate reasons based on similarity scores

### Step 3: Approve Changes

Click the "Approve" button

### Step 4: Verify Operation

1. Restart the application

    Enter the following in IBM Bob's chat screen:
    
    ```text
    Restart the demo application
    ```
    
    ??? tip "If restarting manually"
        1. Press ++ctrl+c++ in the terminal (stop)
            
            **Note**: If you started via IBM Bob, you cannot access the terminal that Bob operates, so this stop operation is not possible.
        
        2. Execute **`python app.py`** ([:material-play-circle: How to start](../part1/#app-restart))
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
         "similarity_score": 0.95,
         "recommendation_reason": "Very high similarity with search content (95%)"
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
    2. Restart the application
    
        Enter the following in IBM Bob's chat screen:
        
        ```text
        Restart the demo application
        ```
        
        ??? tip "If restarting manually"
            1. Press ++ctrl+c++ in the terminal (stop)
                
                **Note**: If you started via IBM Bob, you cannot access the terminal that Bob operates, so this stop operation is not possible.
            
            2. Execute **`python app.py`** ([:material-play-circle: How to start](../part1/#app-restart))
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