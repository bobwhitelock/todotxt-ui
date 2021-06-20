import { TaskForm } from "components/TaskForm";
import {
  useQueryParams,
  getContextParams,
  getProjectParams,
} from "queryParams";
import { pluralizeTasks } from "types";
import { useUpdateTasks } from "api";

export function Add() {
  const params = useQueryParams();
  const contexts = getContextParams(params);
  const projects = getProjectParams(params);

  const useUseUpdateTasksWithTasks = (rawTasks: string) =>
    useUpdateTasks("add", [rawTasks]);

  const getSubmitButtonText = ({
    plural,
    loading,
  }: {
    plural: boolean;
    loading: boolean;
  }) => {
    const taskOrTasks = pluralizeTasks(plural);
    return loading ? `Adding ${taskOrTasks}...` : `Add ${taskOrTasks}`;
  };

  return (
    <TaskForm
      useUseUpdateTasksWithTasks={useUseUpdateTasksWithTasks}
      getSubmitButtonText={getSubmitButtonText}
      contexts={contexts}
      projects={projects}
    />
  );
}
