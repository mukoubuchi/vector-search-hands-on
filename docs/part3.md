# Part 3: Verification and Review

In this part, you'll verify that the 3 features added in Part 2 work correctly and use IBM Bob's code review feature.

## Goals of This Part

- Test the added features
- Use IBM Bob's code review feature
- Verify code quality

## Step 1: Test the Added Features

!!! example "Practice: Let's test the added features"
    
    Test the 3 features added in Part 2.

### Test 1: Product Image Display

#### Procedure

1. Open Swagger UI (**`http://localhost:8002/docs`**)
2. Open the **`/search`** endpoint
3. Click "Try it out"
4. Enter the following:

   ```json
   {
     "query": "red sneakers"
   }
   ```

5. Click "Execute"
6. Verify results:

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

#### Verification Points

- **`image_url`** field exists
- URL is in correct format (starts with **`https://`**)
- All search results include image URL

### Test 2: Price Filter

#### Procedure

1. Open **`/search`** in Swagger UI
2. Click "Try it out"
3. Enter the following:

   ```json
   {
     "query": "sneakers",
     "filters": {
       "price_range": {
         "min": 5000,
         "max": 10000
       }
     }
   }
   ```

4. Click "Execute"
5. Verify results: All product prices are within the 5000-10000 yen range

#### Verification Points

- Only products within the specified price range are displayed
- Products outside the range are not displayed

#### Try Various Price Ranges

```json
// High price range
{
  "query": "camera",
  "filters": {
    "price_range": {
      "min": 50000,
      "max": 100000
    }
  }
}

// Low price range
{
  "query": "camera",
  "filters": {
    "price_range": {
      "min": 0,
      "max": 20000
    }
  }
}
```

### Test 3: Recommendation Reason Display

#### Procedure

1. Open **`/search`** in Swagger UI
2. Click "Try it out"
3. Enter the following:

   ```json
   {
     "query": "beginner camera"
   }
   ```

4. Click "Execute"
5. Verify results:

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

#### Verification Points

- **`recommendation_reason`** field exists
- Reason is displayed in clear language
- Explanation is based on similarity score

### Test Completion Check

- [ ] Product images are displayed
- [ ] Price filter works
- [ ] Recommendation reason is displayed
- [ ] All features work correctly

## Step 2: Use IBM Bob's Code Review Feature

!!! example "Practice: Request a code review"
    
    Have IBM Bob check the code quality.

### What is Code Review?

**Code review** = Verifying code quality

**Purpose**:

- Find bugs
- Discover improvement points
- Learn best practices

### Step 1: Request Review

Enter the following in the chat input field and press Enter:

```text
/review app.py
```

!!! tip "How to Use the Command"
    
    Using the `/review` command, IBM Bob will execute a code review.

### Step 2: Review IBM Bob's Review Results

IBM Bob will perform analysis like the following:

```
Code Review Results:

Good points:
✓ Code is readable
✓ Appropriate error handling
✓ Functions are properly divided

Improvement points:
⚠ Adding log output would be good
⚠ Having test code would be good
⚠ Adding documentation comments would be good

Security:
✓ No particular issues

Performance:
✓ Efficient implementation
```

### Step 4: Review Improvement Points

Review the improvement points IBM Bob pointed out.

**Common improvement points**:

- Adding log output
- Strengthening error handling
- Adding documentation comments
- Creating test code

### Step 5: Request Improvements (Optional)

If there are points you want to improve, request IBM Bob:

```text
Add log output
```

## Part 3 Completion Check

- [ ] Tested all 3 features added in Part 2
- [ ] Used the `/review` command to request code review from IBM Bob
- [ ] Reviewed review results and understood improvement points

## FAQ

??? question "Q1: Test fails"

    Solution:
    
    1. Verify application is running
    2. Verify changes are saved
    3. Restart the application
    
        Enter the following in IBM Bob's chat screen:
        
        ```text
        Restart the demo application
        ```
        
        ??? tip "If restarting manually"
            1. Press ++ctrl+c++ in the terminal (stop)
                
                **Note**: If you started via IBM Bob, you cannot access the terminal that Bob operates, so this stop operation is not possible.
            
            2. Execute **`python app.py`** ([:material-play-circle: How to start](../part1/#app-restart))

??? question "Q2: Review results are not displayed"

    Solution:
    
    1. Verify `/review` command was entered correctly
    2. Verify file name is correct
    3. Restart IBM Bob

## Step 3: Environment Cleanup

!!! example "Practice: Clean up installed packages"
    
    Uninstall Python packages used in the hands-on to clean up the environment.

### Purpose of Cleanup

In this hands-on, we installed multiple packages using `pip`. After the hands-on, if these packages are no longer needed, we recommend uninstalling them to keep the environment clean.

### Request IBM Bob to Clean Up

Enter the following in IBM Bob's chat input field:

```text
Uninstall all packages listed in setup/participant/requirements.txt
```

!!! info "Packages to be Uninstalled"
    
    The following packages will be uninstalled:
    
    - pymilvus
    - sentence-transformers
    - torch
    - python-dotenv
    - pandas
    - scikit-learn
    - langchain
    - langchain-community
    - tqdm
    - Other dependency packages

??? tip "If uninstalling manually"
    If uninstalling manually without using IBM Bob, execute the following in the terminal:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder
        pip3 uninstall -y -r setup/participant/requirements.txt
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        cd %USERPROFILE%\Desktop\vector-search-builder
        pip uninstall -y -r setup\participant\requirements.txt
        ```

??? question "Q: What if I want to keep the packages?"
    
    If you plan to use the technologies learned in this hands-on in the future, you don't need to uninstall the packages. You can leave them as is and reuse them in your next project.

### Cleanup Completion Check

- [ ] Requested IBM Bob to uninstall packages
- [ ] Uninstallation completed successfully
- [ ] Environment is clean

## Next Steps

Once Part 3 is complete, proceed to [Summary](summary.md)!