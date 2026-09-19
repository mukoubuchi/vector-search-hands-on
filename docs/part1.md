# Part 1: Experience Vector Search

In this part you load a small product catalogue into OpenSearch and ask it the same questions three different ways.

## Goals of This Part

- See what an embedding is, by generating some
- Run keyword, vector and hybrid search over one index
- Find the questions where each one fails

## Step 1: Run the Connection Test

This hands-on talks to two services: OpenSearch, which stores the products, and watsonx.ai, which turns text into vectors. Check both before going further.

```bash
cd setup/participant
python test_connection.py
```

### Verify Results

```text
==================================================
OpenSearch and watsonx.ai Connection Test
==================================================

=== Environment Variable Check ===
✓ OPENSEARCH_HOST: ...
✓ OPENSEARCH_PASSWORD: ********
✓ IBM_API_KEY: ********

=== OpenSearch Connection Test ===
✓ Connected to OpenSearch successfully (version 3.8.0)
✓ k-NN plugin is available (opensearch-knn)
✓ Cluster status: green

=== watsonx.ai Embeddings Test ===
✓ Embedding generated: ibm/granite-embedding-278m-multilingual
✓ Vector dimension: 768
```

The last line is the number that matters for the next step: the embedding model returns **768 numbers** for any text you give it, and the index has to be built for exactly that many.

??? question "Something failed"

    - **OpenSearch connection error**: check `OPENSEARCH_HOST`, `OPENSEARCH_PORT` and `OPENSEARCH_PASSWORD` in `setup/participant/.env` against what the instructor gave you.
    - **watsonx.ai error**: check `IBM_API_KEY` and `WATSONX_PROJECT_ID`. An API key belongs to an account; a project ID belongs to a project inside it, and both have to be yours.
    - **Placeholder still in .env**: the scripts refuse a value that still looks like `<something>`, and name the variable in the error.

## Step 2: Create the Index and Load the Products

```bash
python insert_sample_data.py
```

The script asks watsonx.ai for one embedding, uses its length to create the index, embeds the twelve sample products, and bulk-loads them.

### What Gets Created

```json
{
  "product_name": { "type": "text" },
  "description":  { "type": "text" },
  "category":     { "type": "keyword" },
  "price":        { "type": "integer" },
  "embedding":    {
    "type": "knn_vector",
    "dimension": 768,
    "space_type": "cosinesimil",
    "method": { "name": "hnsw", "engine": "faiss",
                "parameters": { "ef_construction": 128, "m": 24 } }
  }
}
```

Two things are worth noticing:

- **The same document carries both kinds of data.** `product_name` and `description` are analysed for BM25; `embedding` holds the vector. One index answers both kinds of query, which is why hybrid search is possible at all.
- **`dimension` must match the model.** 768 is what `ibm/granite-embedding-278m-multilingual` returns. Change `EMBEDDING_MODEL_ID` and the index has to be rebuilt.

??? note "HNSW, briefly"

    Comparing a query against every vector is exact but slow. HNSW builds a navigable graph over the vectors and walks it, trading a little recall for a lot of speed. `m` is how many neighbours each node keeps, `ef_construction` how hard the build works to find good ones. The Building Block's workflow recommends `ef_construction=128, m=24` as the balanced starting point, and that is what the kit uses.

## Step 3: Start the Demo Application

```bash
python app.py
```

Open the interactive API documentation at [http://localhost:8002/docs](http://localhost:8002/docs) — you can run every query below from that page instead of the terminal, if you prefer.

## Step 4: Ask the Same Question Three Ways

`/search` takes a `mode`. Run each question in all three modes and watch the ranking move.

```bash
curl -s -X POST http://localhost:8002/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "red sneakers", "mode": "keyword", "top_k": 3}'
```

Change `"mode"` to `"vector"` and then to `"hybrid"` and run it again.

### The Four Questions

The first two use the catalogue's own words. The last two do not.

| # | Question | What it is testing |
|:--|:---|:---|
| 1 | `red sneakers` | Words that appear in the data |
| 2 | `cheap running shoes` | Words that appear, plus a judgement ("cheap") |
| 3 | `footwear for working out` | The idea of a training shoe, in none of its words |
| 4 | `a device for keeping memories from a trip` | A camera, described the way a shopper might |

Fill this in as you go:

| Question | `keyword` top hit | `vector` top hit | `hybrid` top hit |
|:---|:---|:---|:---|
| red sneakers | | | |
| cheap running shoes | | | |
| footwear for working out | | | |
| a device for keeping memories from a trip | | | |

### Reading the Response

```json
{
  "mode": "hybrid",
  "results": [
    {
      "product_name": "...",
      "score": 0.87,
      "price": 8900,
      "category": "Sneakers",
      "description": "...",
      "keyword_score": 0.74,
      "vector_score": 1.0
    }
  ]
}
```

In `hybrid` mode every result shows where it came from. `keyword_score` and `vector_score` are each ranking's score rescaled to 0–1, and `score` is the blend. A result with `keyword_score: 0.0` was found only by the vector side — the words never matched.

!!! info "Why the scores are rescaled"

    BM25 scores have no upper bound and depend on the corpus; k-NN similarities sit in their own range. Adding them raw would let whichever number happens to be larger decide the ranking. Min-max normalising each list first puts both on 0–1, which is the step the Building Block's workflow calls "score normalisation".

### Try the Weighting

`vector_weight` decides how much the vector side counts in `hybrid` mode. The default is `0.5`.

```bash
curl -s -X POST http://localhost:8002/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "footwear for working out", "mode": "hybrid", "vector_weight": 0.9}'
```

Run the same question at `0.1` and at `0.9`. At `0.1` you are close to keyword search; at `0.9` you are close to vector search.

## Step 5: What You Just Saw

- **Questions 1 and 2** are the case keyword search was built for. Vector search usually finds the same products, sometimes in a different order.
- **Questions 3 and 4** have no words in common with the catalogue. Keyword search has nothing to match on; the vector side carries the result.
- **Hybrid** keeps both behaviours. That is why production search engines rarely pick one.

!!! success "Checkpoint"

    You have one index that answers lexical and semantic queries, and you can see which side produced each hit. Part 2 hands the next change to IBM Bob.

[Next →](part2.md){ .workshop-next }
