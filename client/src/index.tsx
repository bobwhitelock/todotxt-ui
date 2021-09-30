import React from "react";
import ReactDOM from "react-dom";
import * as Sentry from "@sentry/react";
import { Integrations } from "@sentry/tracing";

import "index.css";
import { App } from "components/App";
import { reportWebVitals } from "reportWebVitals";

Sentry.init({
  dsn:
    process.env.NODE_ENV === "production"
      ? "https://4de4eb1ce60f4037a7a8febb6ff59100@o383461.ingest.sentry.io/5987296"
      : "",
  integrations: [new Integrations.BrowserTracing()],

  // Set `tracesSampleRate` to 1.0 to capture 100% of transactions for
  // performance monitoring. Sentry recommend adjusting this value in
  // production, but possibly this doesn't matter in our case as number of
  // users will always be very low.
  tracesSampleRate: 1.0,
});

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById("root")
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
