import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "react-query";
import { Helmet } from "react-helmet";

import * as urls from "urls";
import { Add } from "components/pages/Add";
import { Edit } from "components/pages/Edit";
import { Root } from "components/pages/Root";

const queryClient = new QueryClient();

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Helmet defaultTitle="todotxt-ui" titleTemplate="todotxt-ui | %s" />
      <Router>
        <Switch>
          {/* XXX Handle 404s */}
          <Route exact path={urls.root}>
            <Root />
          </Route>
          <Route exact path={urls.add}>
            <Add />
          </Route>
          <Route exact path={urls.edit.template}>
            <Edit />
          </Route>
        </Switch>
      </Router>
    </QueryClientProvider>
  );
}
