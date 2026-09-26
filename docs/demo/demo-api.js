// Browser demo: stands in for the hands-on API, so the participant search
// screen (app.js, unchanged) runs without a server. It answers the requests
// app.js sends to /openapi.json, /health, and /search; the search itself runs
// in demo-model.js once the embedding model has loaded in the browser.

"use strict";

(() => {
  // Language: ?lang=ja or ?lang=en, remembered for the next visit
  const params = new URLSearchParams(window.location.search);
  let lang = params.get("lang");
  try {
    if (!lang) lang = window.localStorage.getItem("demo-lang");
  } catch (error) {
    lang = lang || null;
  }
  lang = lang === "ja" ? "ja" : "en";
  try {
    window.localStorage.setItem("demo-lang", lang);
  } catch (error) {
    // Storage may be unavailable (private mode); the query string still works
  }
  document.documentElement.lang = lang;

  let provideSearch;
  const searchReady = new Promise((resolve) => {
    provideSearch = resolve;
  });
  window.demoApi = { lang, provideSearch };

  // The same request fields as the API after Part 2 (the price filter turns on)
  const OPENAPI = {
    openapi: "3.1.0",
    info: { title: "Product search (browser demo)", version: "1" },
    paths: {
      "/search": {
        post: {
          requestBody: {
            content: { "application/json": { schema: { $ref: "#/components/schemas/SearchRequest" } } },
          },
        },
      },
    },
    components: {
      schemas: {
        SearchRequest: {
          type: "object",
          required: ["query"],
          properties: {
            query: { type: "string", minLength: 1 },
            top_k: { type: "integer", minimum: 1, maximum: 100, default: 5 },
            min_price: { type: "integer", minimum: 0 },
            max_price: { type: "integer", minimum: 0 },
          },
        },
      },
    },
  };

  const reply = (body, status = 200) =>
    new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });

  const originalFetch = window.fetch.bind(window);
  window.fetch = async (input, init = {}) => {
    const url = new URL(typeof input === "string" ? input : input.url, window.location.href);
    if (url.origin === window.location.origin) {
      if (url.pathname === "/openapi.json") return reply(OPENAPI);
      if (url.pathname === "/health") return reply({ status: "healthy", engine: "browser" });
      if (url.pathname === "/search") {
        let request;
        try {
          request = JSON.parse(init.body || "{}");
        } catch (error) {
          return reply({ detail: "Invalid JSON" }, 422);
        }
        const query = typeof request.query === "string" ? request.query.trim() : "";
        const topK = Number.isInteger(request.top_k) ? request.top_k : 5;
        const minPrice = Number.isInteger(request.min_price) ? request.min_price : null;
        const maxPrice = Number.isInteger(request.max_price) ? request.max_price : null;
        if (query === "" || topK < 1 || topK > 100 || (minPrice !== null && minPrice < 0) || (maxPrice !== null && maxPrice < 0)) {
          return reply({ detail: "Invalid search request" }, 422);
        }
        const search = await searchReady;
        const results = await search({ query, topK, minPrice, maxPrice });
        return reply({ results });
      }
    }
    return originalFetch(input, init);
  };
})();
