import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "react-query";
import { Helmet, HelmetProvider } from "react-helmet-async";

import * as paths from "paths";
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
            <Route path={paths.root.pattern} element={<Root />} />
            <Route path={paths.add.pattern} element={<Add />} />
            <Route path={paths.edit.pattern} element={<Edit />} />
          </Routes>
        </Router>
      </HelmetProvider>
    </QueryClientProvider>
  );
}
