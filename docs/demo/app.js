// Product search screen for the vector search demo API.
//
// The screen is a thin client: it sends the query to POST /search and shows
// the fields the API returns. Optional fields appear when the API starts to
// return them (image_url, recommendation_reason), and the price filter turns
// on when the API accepts min_price and max_price, so adding those features
// to the API is enough to see them here.

"use strict";

// Shop name shown in the page title and header; change it here only.
const SHOP_NAME = {
  en: "Product Search Demo",
  ja: "商品検索デモ",
};

// Similarity bands that colour the bar (highest first). The docs describe
// the same thresholds, so change them together.
const SIMILARITY_BANDS = [
  { min: 0.7, level: "high" },
  { min: 0.4, level: "mid" },
  { min: 0, level: "low" },
];

const TEXT = {
  en: {
    queryLabel: "Search products",
    queryPlaceholder: "Describe what you want, e.g. red sneakers",
    searchButton: "Search",
    examplesLabel: "Try:",
    examples: ["red sneakers", "beginner camera", "business laptop", "high-performance gaming PC"],
    topKLabel: "Results (top_k)",
    priceLabel: "Price (USD)",
    priceMin: "Minimum price",
    priceMax: "Maximum price",
    priceMinPlaceholder: "Min",
    priceMaxPlaceholder: "Max",
    priceNote: "Available once the search API accepts min_price and max_price (Part 2, Feature 2).",
    priceRangeInvalid: "The minimum price must not be higher than the maximum price.",
    idle: "Enter what you are looking for, in your own words.",
    searching: "Searching…",
    resultCount: (count, query) => `${count} ${count === 1 ? "result" : "results"} for “${query}”`,
    noResults: "No products matched. Try other words or a wider price range.",
    unreachableTitle: "Cannot reach the search API.",
    unreachableDetail: "Check that the app is running (python app.py), then search again.",
    notReadyTitle: "Search is not ready.",
    errorTitle: (status) => `The search API returned an error (HTTP ${status}).`,
    similarity: "Similarity",
    legendTitle: "Similarity:",
    bandLabel: (min, upper) => (upper === null ? `${min} and above` : min === 0 ? `below ${upper}` : `${min}–${upper}`),
    reason: "Why this product",
    imageMissing: "No image",
    formatPrice: (price) => `$${price.toLocaleString("en-US")}`,
    priceStep: 10,
  },
  ja: {
    queryLabel: "商品を検索",
    queryPlaceholder: "探しているものを言葉で入力（例: 赤いスニーカー）",
    searchButton: "検索",
    examplesLabel: "例:",
    examples: ["赤いスニーカー", "初心者向けのカメラ", "ビジネス向けのノートパソコン", "高性能なゲーミング PC"],
    topKLabel: "表示件数（top_k）",
    priceLabel: "価格（円）",
    priceMin: "最低価格",
    priceMax: "最高価格",
    priceMinPlaceholder: "下限",
    priceMaxPlaceholder: "上限",
    priceNote: "検索 API が min_price と max_price を受け付けると使えます（Part 2 の機能 2）。",
    priceRangeInvalid: "下限の価格は上限以下にしてください。",
    idle: "探しているものを、自分の言葉で入力してください。",
    searching: "検索中…",
    resultCount: (count, query) => `「${query}」の検索結果: ${count} 件`,
    noResults: "該当する商品がありません。言葉を変えるか、価格の範囲を広げてください。",
    unreachableTitle: "検索 API に接続できません。",
    unreachableDetail: "アプリケーション（python app.py）が起動しているか確認してから、もう一度検索してください。",
    notReadyTitle: "検索の準備ができていません。",
    errorTitle: (status) => `検索 API がエラーを返しました（HTTP ${status}）。`,
    similarity: "類似度",
    legendTitle: "類似度:",
    bandLabel: (min, upper) => (upper === null ? `${min} 以上` : min === 0 ? `${upper} 未満` : `${min}〜${upper}`),
    reason: "おすすめ理由",
    imageMissing: "画像なし",
    formatPrice: (price) => `${price.toLocaleString("ja-JP")} 円`,
    priceStep: 1000,
  },
};

const lang = document.documentElement.lang === "ja" ? "ja" : "en";
const t = TEXT[lang];

const form = document.getElementById("search-form");
const queryInput = document.getElementById("query");
const searchButton = document.getElementById("search-button");
const topKSelect = document.getElementById("top-k");
const priceFilter = document.getElementById("price-filter");
const priceNote = document.getElementById("price-note");
const minPriceInput = document.getElementById("min-price");
const maxPriceInput = document.getElementById("max-price");
const statusBox = document.getElementById("status");
const legend = document.getElementById("legend");
const resultList = document.getElementById("results");

let priceFilterSupported = false;
let pendingSearch = null;

function el(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function applyText() {
  document.title = SHOP_NAME[lang];
  document.querySelectorAll("[data-text]").forEach((node) => {
    node.textContent = node.dataset.text === "shopName" ? SHOP_NAME[lang] : t[node.dataset.text];
  });
  queryInput.placeholder = t.queryPlaceholder;
  minPriceInput.placeholder = t.priceMinPlaceholder;
  maxPriceInput.placeholder = t.priceMaxPlaceholder;
  // The sample prices are in US dollars in English and in yen in Japanese
  minPriceInput.step = String(t.priceStep);
  maxPriceInput.step = String(t.priceStep);

  const examples = document.getElementById("examples");
  t.examples.forEach((example) => {
    const chip = el("button", "example", example);
    chip.type = "button";
    chip.addEventListener("click", () => {
      queryInput.value = example;
      runSearch();
    });
    examples.append(chip);
  });
}

function similarityLevel(score) {
  return SIMILARITY_BANDS.find((band) => score >= band.min).level;
}

// Legend for the bar colours, built from SIMILARITY_BANDS
function renderLegend() {
  legend.replaceChildren(el("span", "legend-title", t.legendTitle));
  SIMILARITY_BANDS.forEach((band, index) => {
    const upper = index > 0 ? SIMILARITY_BANDS[index - 1].min : null;
    const item = el("span", "legend-item");
    item.append(el("span", `legend-swatch band--${band.level}`), el("span", "", t.bandLabel(band.min, upper)));
    legend.append(item);
  });
}

function showStatus(message, kind = "info", detail = "") {
  legend.hidden = true;
  statusBox.replaceChildren();
  statusBox.className = `status status--${kind}`;
  statusBox.append(el("p", "status-title", message));
  if (detail) statusBox.append(el("p", "status-detail", detail));
}

// Follow "$ref" pointers such as "#/components/schemas/SearchRequest".
function resolveSchema(spec, schema) {
  let node = schema;
  for (let depth = 0; node && node.$ref && depth < 10; depth += 1) {
    node = node.$ref.replace(/^#\//, "").split("/").reduce((part, key) => (part ? part[key] : undefined), spec);
  }
  return node;
}

// The price filter is usable only when the /search request body declares
// both min_price and max_price in the API's OpenAPI description.
async function detectPriceFilter() {
  let supported = false;
  try {
    const response = await fetch("/openapi.json", { cache: "no-store" });
    if (response.ok) {
      const spec = await response.json();
      const operation = spec.paths && spec.paths["/search"] && spec.paths["/search"].post;
      const content = operation && operation.requestBody && operation.requestBody.content;
      const schema = resolveSchema(spec, content && content["application/json"] && content["application/json"].schema);
      const properties = (schema && schema.properties) || {};
      supported = "min_price" in properties && "max_price" in properties;
    }
  } catch (error) {
    supported = false;
  }
  priceFilterSupported = supported;
  priceFilter.disabled = !supported;
  priceNote.hidden = supported;
}

function readPrice(input) {
  if (input.value.trim() === "") return null;
  const value = Number(input.value);
  return Number.isFinite(value) ? Math.round(value) : null;
}

function safeImageUrl(value) {
  if (typeof value !== "string" || value.trim() === "") return null;
  try {
    const url = new URL(value, window.location.href);
    return url.protocol === "http:" || url.protocol === "https:" ? url.href : null;
  } catch (error) {
    return null;
  }
}

function renderCard(item, rank) {
  const card = el("li", "card");

  const imageUrl = safeImageUrl(item.image_url);
  if (imageUrl) {
    const frame = el("div", "card-image");
    const image = el("img");
    image.src = imageUrl;
    image.alt = item.product_name || "";
    image.decoding = "async";
    image.addEventListener("error", () => {
      frame.classList.add("card-image--missing");
      frame.replaceChildren(el("span", "", t.imageMissing));
    });
    frame.append(image);
    card.append(frame);
  }

  const body = el("div", "card-body");
  const meta = el("div", "card-meta");
  meta.append(el("span", "card-rank", `#${rank}`));
  if (item.category) meta.append(el("span", "card-category", item.category));
  body.append(meta);

  body.append(el("h2", "card-title", item.product_name || ""));
  if (typeof item.price === "number") body.append(el("p", "card-price", t.formatPrice(item.price)));
  if (item.description) body.append(el("p", "card-description", item.description));

  if (typeof item.similarity_score === "number") {
    const score = Math.max(0, Math.min(1, item.similarity_score));
    const similarity = el("div", "similarity");
    const label = el("div", "similarity-label");
    label.append(el("span", "", t.similarity), el("span", "similarity-value", item.similarity_score.toFixed(4)));
    const bar = el("div", "similarity-bar");
    const fill = el("div", `similarity-fill band--${similarityLevel(score)}`);
    fill.style.width = `${(score * 100).toFixed(1)}%`;
    bar.append(fill);
    similarity.append(label, bar);
    body.append(similarity);
  }

  if (typeof item.recommendation_reason === "string" && item.recommendation_reason.trim() !== "") {
    const reason = el("div", "card-reason");
    reason.append(el("p", "card-reason-label", t.reason), el("p", "card-reason-text", item.recommendation_reason));
    body.append(reason);
  }

  card.append(body);
  return card;
}

function errorDetail(payload) {
  if (!payload || payload.detail === undefined) return "";
  if (typeof payload.detail === "string") return payload.detail;
  if (Array.isArray(payload.detail)) {
    return payload.detail.map((entry) => (entry && entry.msg) || JSON.stringify(entry)).join(" / ");
  }
  return JSON.stringify(payload.detail);
}

async function runSearch() {
  const query = queryInput.value.trim();
  if (query === "") {
    queryInput.focus();
    showStatus(t.idle);
    return;
  }

  const request = { query, top_k: Number(topKSelect.value) };
  if (priceFilterSupported) {
    const minPrice = readPrice(minPriceInput);
    const maxPrice = readPrice(maxPriceInput);
    if (minPrice !== null && maxPrice !== null && minPrice > maxPrice) {
      showStatus(t.priceRangeInvalid, "error");
      return;
    }
    if (minPrice !== null) request.min_price = minPrice;
    if (maxPrice !== null) request.max_price = maxPrice;
  }

  // Keep the query in the address bar so that reloading the page repeats it
  const params = new URLSearchParams({ q: query, top_k: String(request.top_k) });
  window.history.replaceState(null, "", `?${params}`);

  if (pendingSearch) pendingSearch.abort();
  const controller = new AbortController();
  pendingSearch = controller;
  searchButton.disabled = true;
  showStatus(t.searching, "busy");

  let response;
  try {
    response = await fetch("/search", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(request),
      signal: controller.signal,
    });
  } catch (error) {
    if (controller.signal.aborted) return;
    pendingSearch = null;
    searchButton.disabled = false;
    resultList.replaceChildren();
    showStatus(t.unreachableTitle, "error", t.unreachableDetail);
    return;
  }

  let payload = null;
  try {
    payload = await response.json();
  } catch (error) {
    payload = null;
  }
  if (controller.signal.aborted) return;
  pendingSearch = null;
  searchButton.disabled = false;

  if (!response.ok) {
    resultList.replaceChildren();
    const title = response.status === 503 ? t.notReadyTitle : t.errorTitle(response.status);
    showStatus(title, "error", errorDetail(payload));
  } else {
    const results = (payload && Array.isArray(payload.results)) ? payload.results : [];
    resultList.replaceChildren(...results.map((item, index) => renderCard(item, index + 1)));
    if (results.length === 0) {
      showStatus(t.noResults, "empty");
    } else {
      showStatus(t.resultCount(results.length, query), "done");
      legend.hidden = false;
    }
  }

  // The API may have been restarted with new features; check again
  detectPriceFilter();
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  runSearch();
});

async function start() {
  applyText();
  renderLegend();
  showStatus(t.idle);
  await detectPriceFilter();

  // Repeat the search in the address bar (for example after a reload)
  const params = new URLSearchParams(window.location.search);
  const topK = params.get("top_k");
  if (topK && [...topKSelect.options].some((option) => option.value === topK)) topKSelect.value = topK;
  if (params.get("q")) {
    queryInput.value = params.get("q");
    runSearch();
  } else {
    queryInput.focus();
  }
}

start();
