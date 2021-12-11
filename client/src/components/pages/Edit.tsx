import { Navigate } from "react-router-dom";

import { TaskForm } from "components/TaskForm";
import { useUpdateTasks } from "api";
import { useDecodedParams } from "hooks";
import * as paths from "paths";

export function Edit() {
  const { rawTask: initialRawTask } = useDecodedParams();
  if (!initialRawTask) {
    // We should never be here without this param, if we somehow are just go
    // back to the root page.
    return <Navigate to={paths.root({})} />;
  }

  const useUseUpdateTasksWithTasks = (rawTask: string) =>
    useUpdateTasks({
      type: "update",
      arguments: { task: initialRawTask, newTask: rawTask },
    });

  const getSubmitButtonText = ({ loading }: { loading: boolean }) =>
    loading ? "Updating Task..." : "Update Task";

  return (
    <TaskForm
      initialRawTask={initialRawTask}
      useUseUpdateTasksWithTasks={useUseUpdateTasksWithTasks}
      getSubmitButtonText={getSubmitButtonText}
    />
  );
}
