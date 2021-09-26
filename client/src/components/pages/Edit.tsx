import { TaskForm } from "components/TaskForm";
import { useUpdateTasks } from "api";
import { useDecodedParams } from "hooks";

export function Edit() {
  const { rawTask: initialRawTask } = useDecodedParams<{ rawTask: string }>();

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
