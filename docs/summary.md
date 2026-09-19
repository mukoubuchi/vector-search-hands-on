# Summary

## What You Built

In about an hour you went from an empty OpenSearch node to a search API that:

- stores products and their **768-dimension watsonx.ai embeddings** in one k-NN index
- answers the same question by **BM25**, by **k-NN**, or by both with normalised scores
- was extended by **IBM Bob**, working from the Building Block IBM publishes for exactly this job

## What to Remember

| Idea | Why it matters |
|:---|:---|
| One index, two kinds of query | Text fields and a `knn_vector` field live on the same document, which is what makes hybrid search possible |
| The dimension is not yours to choose | It comes from the embedding model; change the model and rebuild the index |
| Scores must be normalised before they are blended | BM25 is unbounded, k-NN similarity is not; raw addition lets the bigger scale win |
| Neither mode is "better" | Exact wording favours keyword, described intent favours vector, production usually wants both |

## Taking This to watsonx.data

The hands-on cluster is a container on someone's laptop. IBM watsonx.data provides managed OpenSearch with the same k-NN plugin, and the participant scripts never assume which one they are talking to: host, port, user, password and TLS settings all come from `setup/participant/.env`, under the same variable names the upstream Building Block's ingestion asset uses.

```bash
OPENSEARCH_HOST=your-cluster.databases.appdomain.cloud
OPENSEARCH_PORT=30628
OPENSEARCH_USER=ibm_cloud_user
OPENSEARCH_PASSWORD=...
OPENSEARCH_USE_SSL=true
OPENSEARCH_VERIFY_CERTS=true
```

!!! note "Not verified here"

    This hands-on has not been run against a live watsonx.data OpenSearch cluster. The point above is about how the code is wired — nothing in it is specific to the container — not a tested migration path. Provision a cluster and try it before promising a customer a five-minute switch.

What a real deployment adds beyond this kit: document ingestion from IBM Cloud Object Storage, chunking, an authentication layer in front of the API, index lifecycle management, and — if you are building RAG — a generation step after retrieval. The Building Block's workflow covers those stages too.

## How This Differs from the Existing DSCE Assets

Worth repeating now that you have run it:

- **A kit, not a demonstration.** One repository, one container, one set of credentials, reproducible by anyone.
- **The Building Block is the subject.** You ran the mode and skill IBM publishes, not a rewrite of them.
- **The comparison is the lesson.** Keyword, vector and hybrid over the same index and the same questions.
- **Smallest useful system.** Retrieval only, so every moving part stayed visible.

Assets such as Orbital Suppliers, NexusIQ and Maximo Knowledge Hub show finished solutions to specific problems. This one shows the mechanism, and hands it over.

## Clean Up

Delete your index (it lives on a shared cluster):

```bash
curl -sk -u "admin:$OPENSEARCH_PASSWORD" -X DELETE \
  "https://$OPENSEARCH_HOST:$OPENSEARCH_PORT/$INDEX_NAME"
```

Stop the demo application with ++ctrl+c++.

If you ran the cluster yourself:

```bash
cd setup/instructor
./stop-all.sh
```

## Where to Go Next

- The Building Block sources: [ibm-self-serve-assets/building-blocks](https://github.com/ibm-self-serve-assets/building-blocks)
- [OpenSearch k-NN documentation](https://docs.opensearch.org/latest/vector-search/)
- [watsonx.ai supported embedding models](https://www.ibm.com/docs/en/watsonx/saas?topic=models-supported-embedding)

Thank you for taking part.
