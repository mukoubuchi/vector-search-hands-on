---
name: opensearch-vector-search
description: IBM-focused guidance for OpenSearch vector and hybrid search used with IBM watsonx.data RAG patterns and IBM watsonx.ai embeddings.
---

# OpenSearch Vector Search

Use OpenSearch as the search implementation technology within an IBM watsonx.data RAG/OpenRAG or custom-reference pattern.

## Current IBM model example

- Embedding: `ibm/granite-embedding-278m-multilingual`
- Dimension: `768`

Treat the model ID as configurable and verify current support before deployment.

## Rules

1. Keep OpenSearch vector dimensions aligned with the selected embedding model.
2. Use IBM watsonx.ai for embeddings/generation in this IBM-focused building block.
3. Apply TLS, secret management, access-control filtering, and index-level authorization.
4. Validate vector and hybrid retrieval quality with representative queries.
5. Do not invent IBM/OpenSearch endpoints or availability.

## IBM references

- OpenRAG provisioning: https://www.ibm.com/docs/en/watsonxdata/saas?topic=openrag-provisioning
- Supported embedding models: https://www.ibm.com/docs/en/watsonx/saas?topic=models-supported-embedding
- Model lifecycle: https://www.ibm.com/docs/en/watsonx/saas?topic=model-foundation-lifecycle
