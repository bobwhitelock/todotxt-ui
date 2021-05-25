import { useParams } from "react-router-dom";

import TaskForm from "components/TaskForm";
import { useUpdateTasks } from "api";

export default function Edit() {
  const { rawTask: initialRawTask } = useParams<{ rawTask: string }>();

  const useUseUpdateTasksWithTasks = (rawTask: string) =>
    useUpdateTasks("update", [initialRawTask, rawTask]);

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
