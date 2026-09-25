# Part 3: Verification and Cleanup

In this part, you'll verify that the features added in Part 2 work correctly together, and then clean up the hands-on environment.

## Goals of This Part

- Test the added features
- Clean up the hands-on environment

## Step 1: Test the Added Features

!!! example "Practice: Let's test the added features"
    
    Test the features added in Part 2 without repeating the same verification point.

!!! note "If testing was already completed in Part 2"
    
    During Part 2, IBM Bob may automatically create test scripts and complete the tests after you click the run button. Even in that case, use this step to double-check that the added features work as expected.

!!! note "Test viewpoints"
    
    On the search screen, one search shows all added fields on each product card. Therefore, this section separates testing into **response field verification** and **price filter behavior verification**.

### Test 1: Overall Response Field Verification

#### Procedure

1. Open the search screen (**`http://localhost:8002`**)
2. Search for:

    ```text
    red sneakers
    ```

3. Verify the product cards

#### Verification Points

- A product image is displayed on each card (**`image_url`**)
- A recommendation reason is displayed in clear language (**`recommendation_reason`**)
- The existing product name, price, category, description, and similarity are still displayed

### Test 2: Price Filter Behavior Verification

#### Procedure

1. On the search screen, enter **5000** as the minimum price and **10000** as the maximum price
2. Search for:

    ```text
    sneakers
    ```

3. Verify results: All product prices are within the 5000-10000 yen range

#### Verification Points

- Only products within the specified price range are displayed
- Products outside the range are not displayed
- Product images and recommendation reasons are still displayed

#### Optional: Try Various Price Ranges

| Search query | Minimum price | Maximum price |
|--------------|---------------|---------------|
| camera | 50000 | 100000 |
| camera | 0 | 20000 |

### Test Completion Check

- [ ] Verified product images and recommendation reasons in one search
- [ ] Verified that the price filter excludes products outside the range
- [ ] Verified that the added features work correctly together

## Part 3 Completion Check

- [ ] Tested the features added in Part 2 using non-overlapping verification points

## FAQ

??? question "Q1: Test fails"

    Solution:
    
    1. Verify application is running
    2. Verify changes are saved
    3. Restart the application manually
    
        1. Press ++ctrl+c++ in the terminal running the application (stop)
        2. Execute **`python app.py`** ([:material-play-circle: How to start](part1.md#app-restart))

## Step 2: Environment Cleanup

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

[Next →](summary.md){ .workshop-next }
