import React from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "react-query";

import * as urls from "urls";
import Add from "components/pages/Add";
import Main from "components/pages/Main";

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <Switch>
          {/* XXX Handle 404s */}
          <Route exact path={urls.root}>
            <Main />
          </Route>
          <Route exact path={urls.add}>
            <Add />
          </Route>
        </Switch>
      </Router>
    </QueryClientProvider>
  );
}

export default App;