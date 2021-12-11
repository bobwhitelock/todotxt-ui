import {
  BrowserRouter as Router,
  Routes as ReactRouterRoutes,
  Route,
  Navigate,
} from "react-router-dom";

import * as paths from "paths";
import { useTasks } from "api";
import { TodoFile } from "components/pages/TodoFile";
import { Add } from "components/pages/Add";
import { Edit } from "components/pages/Edit";

export function Routes() {
  const { todoFiles } = useTasks();
  const firstTodoFile = todoFiles[0];
  if (!firstTodoFile) {
    return <span>Loading...</span>;
  }

  return (
    <Router>
      <ReactRouterRoutes>
        {/* TODO Handle 404s, both for arbitrary incorrect routes and todo file */}
        {/* routes for unknown files. */}

        {/* TODO move redirects to server, better according to */}
        {/* https://gist.github.com/mjackson/b5748add2795ce7448a366ae8f8ae3bb#handling-redirects-in-react-router-v6 */}
        <Route
          path={paths.root.pattern}
          element={
            <Navigate to={paths.todoFile({ todoFile: firstTodoFile })} />
          }
        />
        <Route
          path={paths.rootAdd.pattern}
          element={
            <Navigate to={paths.todoFileAdd({ todoFile: firstTodoFile })} />
          }
        />

        <Route path={paths.todoFile.pattern} element={<TodoFile />} />
        <Route path={paths.todoFileAdd.pattern} element={<Add />} />
        <Route path={paths.todoFileEdit.pattern} element={<Edit />} />
      </ReactRouterRoutes>
    </Router>
  );
}
