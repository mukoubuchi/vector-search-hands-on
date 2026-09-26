// Browser demo: runs the hands-on embedding model in the browser with
// Transformers.js and ranks the sample products by cosine similarity, like the
// hands-on API does with Milvus after Part 2 (images, price filter, reasons).
// Both the products and the query are embedded here, with the same runtime.

import { env, pipeline } from "https://cdn.jsdelivr.net/npm/@huggingface/transformers@4.3.0/dist/transformers.min.js";

const MODEL = "Xenova/paraphrase-multilingual-MiniLM-L12-v2";
// The model repository commit the demo was measured with
const REVISION = "2c4055b12046f11709e9df2c122e59ffbdc2f900";
// Measured first-load download: model 118 MB, tokenizer 17 MB, ONNX Runtime 6 MB
const DOWNLOAD_MB = 140;

// The browser's HTTP cache keeps the ONNX Runtime binary, so Transformers.js
// does not need to copy it into the Cache API as well
env.useWasmCache = false;

const TEXT = {
  en: {
    loading: `The first visit downloads the embedding model (about ${DOWNLOAD_MB} MB). Searches start when it is ready.`,
    progress: (percent) => `Loading the model… ${percent}%`,
    ready: "The model is ready. Searches run in your browser.",
    failed: "The model could not be loaded. Check the network connection and reload the page.",
    reason: (score) =>
      score >= 0.7 ? `Closely matches your search (similarity: ${score.toFixed(4)})`
        : score >= 0.4 ? `Related to the search content (similarity: ${score.toFixed(4)})`
          : `Loosely related to your search (similarity: ${score.toFixed(4)})`,
  },
  ja: {
    loading: `初回は埋め込みモデルを読み込みます（約 ${DOWNLOAD_MB} MB）。読み込みが終わると検索できます。`,
    progress: (percent) => `モデルを読み込み中… ${percent}%`,
    ready: "モデルの準備ができました。検索はブラウザの中で動きます。",
    failed: "モデルを読み込めませんでした。ネットワークを確認して、ページを再読み込みしてください。",
    reason: (score) =>
      score >= 0.7 ? `検索内容とよく一致しています（類似度: ${score.toFixed(4)}）`
        : score >= 0.4 ? `検索内容と関連しています（類似度: ${score.toFixed(4)}）`
          : `検索内容と少し関連しています（類似度: ${score.toFixed(4)}）`,
  },
};

const lang = window.demoApi.lang;
const t = TEXT[lang];
const statusBox = document.getElementById("model-status");
const statusText = document.getElementById("model-status-text");
const progressBar = document.getElementById("model-progress");
const searchButton = document.getElementById("search-button");

function showModelStatus(message, percent = null, kind = "loading") {
  statusBox.dataset.state = kind;
  statusText.textContent = message;
  progressBar.hidden = percent === null;
  if (percent !== null) progressBar.value = percent;
}

// Same scoring as the hands-on API: cosine of normalized vectors, clamped to 0-1, 4 decimals
function similarity(a, b) {
  let dot = 0;
  for (let i = 0; i < a.length; i += 1) dot += a[i] * b[i];
  return Math.round(Math.max(0, Math.min(1, dot)) * 10000) / 10000;
}

async function load() {
  searchButton.disabled = true;
  showModelStatus(t.loading, 0);

  // Overall progress across the files the model needs
  const files = new Map();
  const onProgress = (event) => {
    if (event.status !== "progress" || !event.total) return;
    files.set(event.file, { loaded: event.loaded, total: event.total });
    let loaded = 0;
    let total = 0;
    files.forEach((file) => {
      loaded += file.loaded;
      total += file.total;
    });
    showModelStatus(`${t.loading} ${t.progress(Math.floor((loaded / total) * 100))}`, (loaded / total) * 100);
  };

  const extractor = await pipeline("feature-extraction", MODEL, { revision: REVISION, dtype: "q8", progress_callback: onProgress });
  const embed = async (texts) => (await extractor(texts, { pooling: "mean", normalize: true })).tolist();

  const products = await (await fetch(`data/products-${lang}.json`)).json();
  // The text the hands-on embeds for each product (schema.product_text)
  const vectors = await embed(products.map((p) => `${p.product_name} ${p.description}`));

  window.demoApi.provideSearch(async ({ query, topK, minPrice, maxPrice }) => {
    const [queryVector] = await embed([query]);
    return products
      .map((product, index) => ({ product, score: similarity(queryVector, vectors[index]) }))
      .filter(({ product }) => (minPrice === null || product.price >= minPrice) && (maxPrice === null || product.price <= maxPrice))
      .sort((a, b) => b.score - a.score)
      .slice(0, topK)
      .map(({ product, score }) => ({
        product_name: product.product_name,
        similarity_score: score,
        price: product.price,
        category: product.category,
        description: product.description,
        image_url: product.image_url,
        recommendation_reason: t.reason(score),
      }));
  });

  searchButton.disabled = false;
  showModelStatus(t.ready, null, "ready");
}

load().catch((error) => {
  console.error(error);
  showModelStatus(t.failed, null, "failed");
});
