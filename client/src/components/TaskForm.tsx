import { useState } from "react";
import cn from "classnames";
import { Redirect } from "react-router-dom";
import { Helmet } from "react-helmet";

import * as urls from "urls";
import { UpdateTasksMutationResult } from "api";
import { useQueryParams, urlWithParams } from "queryParams";
import { TaskEditor } from "components/TaskEditor";
import { Task } from "types";

type Props = {
  currentTask?: Task;
  contexts?: string[];
  projects?: string[];
  useUseUpdateTasksWithTasks: (rawTasks: string) => {
    mutation: UpdateTasksMutationResult;
    eventHandler: (event: React.SyntheticEvent) => void;
  };
  getSubmitButtonText: ({
    plural,
    loading,
  }: {
    plural: boolean;
    loading: boolean;
  }) => string;
};

// XXX See https://docs.slatejs.org/walkthroughs/06-saving-to-a-database for
// saving stuff - and maybe read rest of docs as well

export function TaskForm({
  currentTask,
  contexts,
  projects,
  useUseUpdateTasksWithTasks,
  getSubmitButtonText,
}: Props) {
  const initialRawTask = currentTask?.raw || "";
  const [rawTasks, setRawTasks] = useState(initialRawTask);
  const trimmedRawTasks = rawTasks.trim();

  const { mutation, eventHandler: onSubmit } =
    useUseUpdateTasksWithTasks(rawTasks);

  const params = useQueryParams();
  if (mutation.isSuccess) {
    return <Redirect to={urlWithParams(urls.root, params)} />;
  }

  // XXX Debounce changing text based on whether loading so doesn't flash very
  // briefly?
  const submitButtonText = getSubmitButtonText({
    plural: trimmedRawTasks.split("\n").length !== 1,
    loading: mutation.isLoading,
  });

  return (
    <>
      <Helmet>
        <title>{submitButtonText}</title>
      </Helmet>

      <form
        className="container flex flex-col h-screen px-4 py-6 mx-auto"
        onSubmit={onSubmit}
      >
        <TaskEditor
          currentTask={currentTask}
          setRawTasks={setRawTasks}
          contexts={contexts || []}
          projects={projects || []}
        />
        <button
          disabled={
            trimmedRawTasks === "" ||
            trimmedRawTasks === initialRawTask ||
            mutation.isLoading
          }
          className={cn(
            "w-full",
            "py-3",
            "mt-3",
            "mb-16",
            "rounded-lg",
            "text-white",
            "bg-green-600",
            "hover:bg-green-800",
            "focus:bg-green-800",
            "font-bold",
            "cursor-pointer",
            "disabled:bg-green-600",
            "disabled:opacity-75",
            "disabled:cursor-auto"
          )}
        >
          {submitButtonText}
        </button>
      </form>
    </>
  );
}
