import TaskForm from "components/TaskForm";
import {
  useQueryParams,
  getContextParams,
  getProjectParams,
} from "queryParams";
import { useUpdateTasks } from "api";

export default function Add() {
  const params = useQueryParams();
  const contexts = getContextParams(params);
  const projects = getProjectParams(params);
  const initialRawTask = [...contexts, ...projects].join(" ");

  const useUseUpdateTasksWithTasks = (rawTasks: string) =>
    useUpdateTasks("add", [rawTasks]);

  const getSubmitButtonText = ({
    plural,
    loading,
  }: {
    plural: boolean;
    loading: boolean;
  }) => {
    const taskOrTasks = plural ? "Tasks" : "Task";
    return loading ? `Adding ${taskOrTasks}...` : `Add ${taskOrTasks}`;
  };

  return (
    <TaskForm
      initialRawTask={initialRawTask}
      useUseUpdateTasksWithTasks={useUseUpdateTasksWithTasks}
      getSubmitButtonText={getSubmitButtonText}
    />
  );
}
