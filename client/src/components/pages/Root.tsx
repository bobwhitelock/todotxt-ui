import { useTasks } from "api";
import { TasksGrid } from "components/TasksGrid";

export function Root() {
  const { todoFiles } = useTasks();

  if (!todoFiles[0]) {
    return <span>Loading...</span>;
  }

  // XXX Just use first todo file for now.
  return <TasksGrid todoFile={todoFiles[0]} />;
}
