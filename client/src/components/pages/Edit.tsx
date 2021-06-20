import { useParams } from "react-router-dom";
import _ from "lodash";
import { Redirect } from "react-router-dom";

import { TaskForm } from "components/TaskForm";
import { useTasks, useUpdateTasks } from "api";
import * as urls from "urls";

export function Edit() {
  const { rawTask } = useParams<{ rawTask: string }>();
  const { tasks } = useTasks();
  const currentTask = _.find(tasks, (task) => task.raw === rawTask);

  if (!currentTask) {
    return <Redirect to={urls.root} />;
  }

  const useUseUpdateTasksWithTasks = (rawTask: string) =>
    useUpdateTasks("update", [currentTask.raw, rawTask]);

  const getSubmitButtonText = ({ loading }: { loading: boolean }) =>
    loading ? "Updating Task..." : "Update Task";

  return (
    <TaskForm
      currentTask={currentTask}
      useUseUpdateTasksWithTasks={useUseUpdateTasksWithTasks}
      getSubmitButtonText={getSubmitButtonText}
    />
  );
}
