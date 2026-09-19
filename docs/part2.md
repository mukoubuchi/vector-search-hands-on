# Part 2: Add Features with IBM Bob

Part 1 ran the search. This part changes it — without you writing the code.

## Goals of This Part

- Add two features by describing them in plain language
- Watch what the Building Block contributes to the answer
- Learn the loop: instruct, read the proposal, approve, verify

## How the Loop Works

1. **Instruct** — say what you want, not how to do it.
2. **Read the proposal** — Bob explains what it will change before it changes anything.
3. **Approve** — accept the edits, or push back and refine.
4. **Verify** — run the request yourself and check the result.

Step 4 is not optional. An agent that edits files is still a tool you are responsible for.

## Feature 1: Filter by Price

Shoppers narrow by budget. Right now `/search` has no way to do that.

=== "IBM Bob IDE"

    With **OpenSearch Vector Search Builder** selected, type this into the chat:

    ```text
    Add an optional maximum price to the /search endpoint, so a caller can ask for
    results under a given price. It should work in all three modes.
    ```

=== "Bob shell"

    !!! warning "Being verified"

        The Bob shell steps are still being checked against version 2.0.4 and will be filled in here. Use the IBM Bob IDE tab in the meantime.

### What to Look For in the Answer

This is the interesting part. A price filter sounds trivial, but in a hybrid search it is not — and the mode knows why:

- A filter on the **keyword** side is another clause in the `bool` query.
- A filter on the **vector** side has to be applied as a **k-NN filter**, not afterwards. Filtering k-NN results after the fact silently returns fewer than `top_k` documents, because the graph walk already decided which vectors to look at.
- In **hybrid** mode the same filter has to reach both sides, or the two rankings disagree about what is eligible.

Read the proposal before accepting it, and see whether it says something about the vector side. That knowledge came from the Building Block's rules, not from the phrasing of your request.

### Verify It

```bash
curl -s -X POST http://localhost:8002/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "footwear for working out", "mode": "hybrid", "max_price": 9000}'
```

Everything returned should cost 9000 or less. Run the same query without `max_price` and confirm that something above the limit disappears — a filter that changes nothing has not been proven to work.

## Feature 2: Explain Why a Result Matched

`hybrid` mode already returns `keyword_score` and `vector_score`. Turn those numbers into something a person can read.

=== "IBM Bob IDE"

    ```text
    For hybrid results, add a short "match_reason" to each result saying whether it
    matched on wording, on meaning, or on both, based on the two component scores.
    ```

=== "Bob shell"

    !!! warning "Being verified"

        The Bob shell steps are still being checked against version 2.0.4 and will be filled in here. Use the IBM Bob IDE tab in the meantime.

### Verify It

```bash
curl -s -X POST http://localhost:8002/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "a gadget for capturing scenery on a trip", "mode": "hybrid"}'
```

The results that keyword search never found should say so.

## If the Answer Is Wrong

It happens. The useful move is to say what is wrong, not to start again:

```text
The filter is applied after the k-NN search, so a filtered query returns fewer
than top_k results. Apply it inside the knn query instead.
```

Bob keeps the context of the file it just edited, so a correction is cheaper than a rewrite. If you want to abandon a change entirely, `git diff` shows exactly what was touched.

!!! tip "Ask it to explain itself"

    ```text
    Why did you apply the filter inside the knn clause rather than after the search?
    ```

    The answer is a fair summary of what the Building Block's rules say about k-NN filtering, and it is worth reading once.

## What Just Happened

You changed a hybrid search engine twice, in plain language, and the changes were right in the places where OpenSearch is easy to get wrong. The specialised knowledge came from a mode that IBM ships and that you installed by unzipping a file.

!!! success "Checkpoint"

    `/search` now filters by price and explains its matches, and you have seen the instruct-review-approve-verify loop end to end.

[Next →](summary.md){ .workshop-next }
