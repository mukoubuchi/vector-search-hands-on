# Part 3: Verification and Review

In this part, you'll verify that the features added in Part 2 work correctly together and request a code review from IBM Bob.

## Goals of This Part

- Test the added features
- Request a code review from IBM Bob
- Verify code quality

## Step 1: Test the Added Features

!!! example "Practice: Let's test the added features"
    
    Test the features added in Part 2 without repeating the same verification point.

!!! note "If testing was already completed in Part 2"
    
    During Part 2, IBM Bob may automatically create test scripts and complete the tests after you click the run button. Even in that case, use this step to double-check that the added features work as expected.

!!! note "Test viewpoints"
    
    In Swagger UI, one search response can show all added response fields. Therefore, this section separates testing into **response field verification** and **price filter behavior verification**.

### Test 1: Overall Response Field Verification

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
          "product_name": "Red Sports Shoes",
          "image_url": "https://example.com/images/red-shoes.jpg",
          "similarity_score": 0.5474,
          "price": 7500,
          "category": "Sneakers",
          "description": "Versatile shoes for both casual and sports use. Excellent cushioning.",
          "recommendation_reason": "Related to the search content (similarity: 0.5474)"
        }
      ]
    }
    ```

#### Verification Points

- **`image_url`** field exists
- URL is in correct format (starts with **`https://`**)
- **`recommendation_reason`** field exists
- Recommendation reason is displayed in clear language
- Existing **`product_name`**, **`price`**, **`category`**, and **`description`** fields are still displayed

### Test 2: Price Filter Behavior Verification

#### Procedure

1. Open **`/search`** in Swagger UI
2. Click "Try it out"
3. Enter the following:

    ```json
    {
      "query": "sneakers",
      "min_price": 5000,
      "max_price": 10000
    }
    ```

4. Click "Execute"
5. Verify results: All product prices are within the 5000-10000 yen range

#### Verification Points

- Only products within the specified price range are displayed
- Products outside the range are not displayed
- **`image_url`** and **`recommendation_reason`** are still displayed

#### Optional: Try Various Price Ranges

```json
// High price range
{
  "query": "camera",
  "min_price": 50000,
  "max_price": 100000
}

// Low price range
{
  "query": "camera",
  "min_price": 0,
  "max_price": 20000
}
```

### Test Completion Check

- [ ] Verified **`image_url`** and **`recommendation_reason`** in one search response
- [ ] Verified that the price filter excludes products outside the range
- [ ] Verified that the added features work correctly together

## Step 2: Request a Code Review from IBM Bob

!!! example "Practice: Request a code review"
    
    Have IBM Bob check the code quality.

### What is Code Review?

**Code review** = Verifying code quality

**Purpose**:

- Find bugs
- Discover improvement points
- Learn best practices

### Request Review

!!! note "About the `/review` command"
    
    IBM Bob has a `/review` command. However, IBM Bob 1.0.3 does not support passing a file name to target a specific file, such as `/review <file>`.
    To review a file, ask in natural language as shown below, such as "Review app.py".

Enter the following in the chat input field and press Enter:

```text
Review app.py
```

!!! tip "IBM Bob's Code Review"
    
    When you request a review, IBM Bob will execute a code review.

Start with `app.py` because it is the API entry point. If Feature 1 changed the product data or Milvus schema, also review the related shared files:

```text
Review schema.py
Review insert_sample_data.py
```

### Review IBM Bob's Review Results

IBM Bob will perform analysis like the following:

#### app.py Code Review

##### ✅ Good Points

###### 1. **Structure and Architecture**

- Clear RESTful API design using FastAPI
- Type-safe request and response models with Pydantic
- Appropriate separation of concerns through imports from `common.py` and `schema.py`

###### 2. **Multilingual Support**

- Japanese / English switching with the `msg()` function
- All user-facing messages support multiple languages

###### 3. **Error Handling**

- Appropriate HTTP status codes (503, 500)
- Exception handling with try-except blocks
- User-friendly error messages
- Modern startup/shutdown handling with a `lifespan` handler
- Input validation for `query` and `top_k` with Pydantic `Field` constraints

###### 4. **Feature Completeness**

- ✅ Vector search
- ✅ Price filter (`min_price`, `max_price`)
- ✅ Automatic recommendation reason generation
- ✅ Health check endpoint

###### 5. **CORS Settings**

- Allows access from the frontend

##### ⚠️ Improvement Suggestions

###### 1. **Use of global variables (lines 24-25)**

```python
# Current
embedding_model: Optional[SentenceTransformer] = None
collection: Optional[Collection] = None

# Recommended: use dependency injection or application state
app.state.embedding_model = None
app.state.collection = None
```

###### 2. **Add validation for the price range added in Part 2**

```python
from pydantic import BaseModel, Field, model_validator

class SearchRequest(BaseModel):
    query: str = Field(min_length=1)
    top_k: int = Field(default=5, ge=1, le=100)
    min_price: Optional[int] = None
    max_price: Optional[int] = None
    
    # Recommended addition
    @model_validator(mode="after")
    def validate_price_range(self):
        if self.min_price is not None and self.max_price is not None:
            if self.max_price < self.min_price:
                raise ValueError("max_price must be greater than or equal to min_price")
        return self
```

###### 3. **Improve logging**

```python
import logging

logger = logging.getLogger(__name__)

# Use logger instead of print()
logger.info(f"Connecting to Milvus: {host}:{port}")
logger.error(f"Failed to connect: {e}")
```

###### 4. **Strengthen security**

```python
# Restrict CORS settings for production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Specific origins only
    allow_credentials=True,
    allow_methods=["GET", "POST"],  # Required methods only
    allow_headers=["*"],
)
```

###### 5. **Optimize performance**

```python
# Add caching for frequently searched queries
from functools import lru_cache

@lru_cache(maxsize=100)
def get_query_embedding(query: str):
    return embedding_model.encode([query], normalize_embeddings=True)[0].tolist()
```

###### 6. **Add tests**

```python
# tests/test_app.py
from fastapi.testclient import TestClient

def test_search_endpoint():
    client = TestClient(app)
    response = client.post("/search", json={"query": "red sneakers"})
    assert response.status_code == 200
    assert "results" in response.json()
```

##### 📊 Code Quality Score

| Item | Score | Comment |
|------|-------|---------|
| Readability | 9/10 | Clear naming and appropriate comments |
| Maintainability | 8/10 | Modularized, but uses global variables |
| Extensibility | 9/10 | Easy to add new features |
| Error handling | 8/10 | Basic handling is implemented |
| Security | 6/10 | CORS settings are permissive |
| Performance | 7/10 | No caching |

**Overall rating: 8.0/10** - Recommended improvements before moving to production

##### 🎯 High-Priority Improvements

1. **Medium**: Add validation for the price range added in Part 2
2. **Medium**: Implement logging for debugging and monitoring
3. **Low**: Tighten CORS settings for production
4. **Low**: Replace global variables with application state

The current code is fully functional and works well as a demo application!

### Review Improvement Points

Review the improvement points IBM Bob pointed out.

**Common improvement points**:

- Adding log output
- Strengthening error handling
- Adding documentation comments
- Creating test code

??? note "How to Treat Improvement Suggestions"
    IBM Bob's review results may include improvement suggestions intended for production environments. Global variables, CORS settings, caching, and additional tests are items to consider when moving toward production.

### Request Improvements (Optional)

If there are points you want to improve, request IBM Bob:

- To add logging:

```text
Add log output to the search processing in app.py
```

- To add validation:

```text
Add min_price and max_price validation to SearchRequest in app.py
```

- To review CORS settings:

```text
Restrict the CORS settings in app.py for production
```

- To add tests:

```text
Add tests for the search endpoint in app.py
```

## Part 3 Completion Check

- [ ] Tested the features added in Part 2 using non-overlapping verification points
- [ ] Requested a code review from IBM Bob
- [ ] Reviewed `schema.py` and data insertion files too if the product data schema changed
- [ ] Reviewed review results and understood improvement points

## FAQ

??? question "Q1: Test fails"

    Solution:
    
    1. Verify application is running
    2. Verify changes are saved
    3. Restart the application manually
    
        1. Press ++ctrl+c++ in the terminal running the application (stop)
        2. Execute **`python app.py`** ([:material-play-circle: How to start](part1.md#app-restart))

??? question "Q2: Review results are not displayed"

    Solution:
    
    1. Verify the review request was entered correctly
    2. Verify file name is correct
    3. Restart IBM Bob

## Step 3: Environment Cleanup

!!! example "Practice: Clean up the virtual environment"
    
    Deactivate the virtual environment used in the hands-on and delete the hands-on folder.

### Purpose of Cleanup

In this hands-on, you worked inside the `vector-search-builder-en` folder on your desktop. When you finish working, first deactivate the virtual environment. Then delete the `vector-search-builder-en` folder from your desktop to remove the hands-on files, project-local `venv`, and configuration files together.

### Request IBM Bob to Clean Up

Enter the following in IBM Bob's chat input field:

```text
Deactivate the Python virtual environment and delete the vector-search-builder-en folder from the desktop.
```

!!! info "How cleanup works"
    
    `deactivate` only exits the virtual environment in the current terminal. Installed packages remain inside the `venv` folder.

    `deactivate` is not included in folder deletion. It resets the current terminal before you delete files.

    Run `deactivate` first, then delete the `vector-search-builder-en` folder created on your desktop. This also removes the project-local `venv` and configuration files.

??? tip "If cleaning up manually"
    Execute the following in the terminal:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        deactivate
        cd ~/Desktop
        rm -rf vector-search-builder-en
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        deactivate
        cd %USERPROFILE%\Desktop
        rmdir /s /q vector-search-builder-en
        ```

??? info "If deleting only venv"
    Usually, deleting the entire `vector-search-builder-en` folder is enough. If you want to keep the project files and remove only the virtual environment, execute the following:

    === ":fontawesome-brands-apple: Mac"
        ```bash
        deactivate
        cd ~/Desktop/vector-search-builder-en/setup/participant
        rm -rf venv
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        deactivate
        cd %USERPROFILE%\Desktop\vector-search-builder-en\setup\participant
        rmdir /s /q venv
        ```

??? question "Q: What if I want to keep the venv?"
    
    If you plan to use the technologies learned in this hands-on in the future, you don't need to delete the `venv` folder. Just run `deactivate` and reuse it later.

### Cleanup Completion Check

- [ ] Deactivated the virtual environment
- [ ] Deleted the `vector-search-builder-en` folder

## Next Steps

Once Part 3 is complete, proceed to [Summary](summary.md)!
