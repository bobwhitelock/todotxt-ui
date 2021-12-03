import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "react-query";
import { Helmet, HelmetProvider } from "react-helmet-async";

import * as urls from "urls";
import { Add } from "components/pages/Add";
import { Edit } from "components/pages/Edit";
import { Root } from "components/pages/Root";

const queryClient = new QueryClient();

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <HelmetProvider>
        <Helmet defaultTitle="todotxt-ui" titleTemplate="%s | todotxt-ui" />
        <Router>
          <Routes>
            <Route path={urls.root} element={<Root />} />
            <Route path={urls.add} element={<Add />} />
            <Route path={urls.edit.template} element={<Edit />} />
          </Routes>
        </Router>
      </HelmetProvider>
    </QueryClientProvider>
  );
}
