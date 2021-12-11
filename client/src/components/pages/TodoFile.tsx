import { useParams, NavLink } from "react-router-dom";
import { Helmet } from "react-helmet-async";
import cn from "classnames";
import _ from "lodash";

import { TodoFile } from "tasks";
import * as paths from "paths";
import { useQueryParams } from "queryParams";
import { incompleteTasks, filterTasks, pluralizeTasks } from "tasks";
import { useTasks } from "api";
import { TasksToolbar } from "components/TasksToolbar";
import { TasksGrid } from "components/TasksGrid";

// Component adapted from
// https://www.creative-tim.com/learning-lab/tailwind-starter-kit/documentation/react/tabs/text.
export { TodoFilePage as TodoFile };
function TodoFilePage() {
  const { todoFiles } = useTasks();
  const params = useQueryParams();

  const { todoFile: currentTodoFileName } = useParams();
  const currentTodoFile = _.find(
    todoFiles,
    (todoFile) => todoFile.fileName === currentTodoFileName
  );

  const titleForTodoFile = (todoFile: TodoFile) => {
    const { tasks, fileName } = todoFile;
    const filteredTasksCount = filterTasks({ tasks, params }).length;
    const incompleteTasks_ = incompleteTasks(tasks);
    const incompleteTasksCount = incompleteTasks_.length;
    const taskOrTasks = pluralizeTasks(incompleteTasks_);

    const tasksSummary =
      filteredTasksCount === incompleteTasksCount
        ? `${incompleteTasksCount} ${taskOrTasks}`
        : `${filteredTasksCount}/${incompleteTasksCount} ${taskOrTasks}`;
    return `${tasksSummary} | ${fileName}`;
  };

  return (
    <>
      <Helmet>
        <title>{currentTodoFile && titleForTodoFile(currentTodoFile)}</title>
      </Helmet>

      <div className="flex flex-wrap">
        <div className="w-full">
          <div className="sticky top-0 p-2 bg-gray-300 border-b-2 border-gray-400 md:static">
            <ul
              className="flex flex-row flex-wrap mb-0 list-none"
              role="tablist"
            >
              {todoFiles.map((todoFile) => (
                <li
                  key={todoFile.fileName}
                  className="flex-auto pt-1 pb-2 mr-2 -mb-px text-center last:mr-0"
                >
                  <NavLink
                    to={paths.todoFile({ todoFile })}
                    className={(isActive) =>
                      cn([
                        "text-xs",
                        "font-bold",
                        "uppercase",
                        "px-5",
                        "py-3",
                        "shadow-lg",
                        "rounded",
                        "block",
                        "leading-normal",
                        "w-full",
                        isActive
                          ? "text-white bg-green-600"
                          : "text-green-600 bg-white",
                      ])
                    }
                  >
                    {todoFile.fileName}
                  </NavLink>
                </li>
              ))}
            </ul>

            {todoFiles.map((todoFile) => (
              <div
                key={todoFile.fileName}
                className={todoFile === currentTodoFile ? "block" : "hidden"}
              >
                <TasksToolbar todoFile={todoFile} />
              </div>
            ))}
          </div>

          <div className="flex flex-col w-full min-w-0 mb-6 break-words bg-white rounded shadow-lg">
            <div className="flex-auto">
              <div className="tab-content tab-space">
                {todoFiles.map((todoFile) => (
                  <div
                    key={todoFile.fileName}
                    className={
                      todoFile === currentTodoFile ? "block" : "hidden"
                    }
                  >
                    <TasksGrid todoFile={todoFile} />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
