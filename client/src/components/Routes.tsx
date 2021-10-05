import {
  BrowserRouter as Router,
  Routes as ReactRouterRoutes,
  Route,
} from "react-router-dom";

import * as paths from "paths";
import { Add } from "components/pages/Add";
import { Edit } from "components/pages/Edit";
import { Root } from "components/pages/Root";

export function Routes() {
  return (
    <Router>
      <ReactRouterRoutes>
        <Route path={paths.root.pattern} element={<Root />} />
        <Route path={paths.add.pattern} element={<Add />} />
        <Route path={paths.edit.pattern} element={<Edit />} />
      </ReactRouterRoutes>
    </Router>
  );
}
