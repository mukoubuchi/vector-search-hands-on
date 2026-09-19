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

Open the interactive API documentation at [http://localhost:8002/docs](http://localhost:8002/docs). You can run every query below from that page instead of the terminal, if you prefer.

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
| 4 | `a gadget for capturing scenery on a trip` | A camera, described the way a shopper might |

Fill this in as you go:

| Question | `keyword` top hit | `vector` top hit | `hybrid` top hit |
|:---|:---|:---|:---|
| red sneakers | | | |
| cheap running shoes | | | |
| footwear for working out | | | |
| a gadget for capturing scenery on a trip | | | |

??? note "Check your results"

    Measured on 2026-09-19 against the twelve sample products with
    `ibm/granite-embedding-278m-multilingual` and the default weight, showing the top hit only.
    Your ordering may differ slightly if the model is updated.

    | Question | `keyword` | `vector` | `hybrid` |
    |:---|:---|:---|:---|
    | red sneakers | Blue Casual Sneakers | Red Sports Shoes | Blue Casual Sneakers |
    | cheap running shoes | Red Running Shoes | Red Running Shoes | Red Running Shoes |
    | footwear for working out | Beginner Mirrorless Camera | Red Training Shoes | Red Training Shoes |
    | a gadget for capturing scenery on a trip | Lightweight Business Bag | Beginner Mirrorless Camera | Beginner Mirrorless Camera |

    Two of these are worth a second look. For **red sneakers** the keyword side wins the blend:
    "sneakers" appears in exactly one product name, and that product is blue. For
    **footwear for working out** the keyword side returns a camera on a score of 0.26: noise,
    which normalisation still promotes to 1.0 before the blend.

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

In `hybrid` mode every result shows where it came from. `keyword_score` and `vector_score` are each ranking's score rescaled to 0–1, and `score` is the blend. A result with `keyword_score: 0.0` was found only by the vector side: the words never matched.

!!! info "Why the scores are rescaled, and what it costs"

    BM25 scores have no upper bound and depend on the corpus; k-NN similarities sit in their own range. Adding them raw would let whichever number happens to be larger decide the ranking. Min-max normalising each list first puts both on 0–1, which is the step the Building Block's workflow calls "score normalisation".

    It has a side effect worth knowing: normalising gives the best hit in each list a 1.0 **even when that list is weak**. Ask question 4 and look at the keyword column. BM25 matched on a common word and returned something confidently wrong, and after normalisation that wrong answer arrives at full strength. This is why the weight below matters.

### Try the Weighting

`vector_weight` decides how much the vector side counts in `hybrid` mode. The default is `0.7`, which is the baseline the Building Block's rules recommend: *"Start with hybrid_score_weight=0.7 (vector) + 0.3 (BM25) as baseline"*.

```bash
curl -s -X POST http://localhost:8002/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "a gadget for capturing scenery on a trip", "mode": "hybrid", "vector_weight": 0.3}'
```

Run the same question at `0.3` and at `0.9`. At `0.3` the keyword side decides and the wrong answer comes back; at `0.9` you are close to pure vector search. The baseline is a starting point for tuning against your own queries, not a constant.

## Step 5: What You Just Saw

- **Questions 1 and 2** use the catalogue's own words, which is the case keyword search was built for. Vector search usually finds the same products, sometimes in a different order.
- **Questions 3 and 4** share no words with the catalogue. Keyword search either finds nothing or latches onto a common word and answers confidently wrong; the vector side carries the result.
- **Question 1 is the one to read twice.** Keyword search ranks the blue sneakers first, because "sneakers" is in that product's name and "red" is not enough to outweigh it. Vector search ranks the red shoes first, because it is matching what the phrase means rather than which characters it contains. Neither is a bug: they are different questions about the same words.
- **Hybrid is a dial, not a winner.** At the default weight of 0.7 it follows the vector side for questions 3 and 4 while keeping exact wording in play for 1 and 2. Turn the dial down and the keyword side takes over, wrong answers included.

!!! success "Checkpoint"

    You have one index that answers lexical and semantic queries, and you can see which side produced each hit. Part 2 hands the next change to IBM Bob.

[Next →](part2.md){ .workshop-next }
