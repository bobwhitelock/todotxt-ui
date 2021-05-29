import { useState } from "react";
import cn from "classnames";
import { Redirect } from "react-router-dom";
import { Helmet } from "react-helmet";

import * as urls from "urls";
import { UpdateTasksMutationResult } from "api";
import { useQueryParams, urlWithParams } from "queryParams";

type Props = {
  initialRawTask: string;
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

export function TaskForm({
  initialRawTask,
  useUseUpdateTasksWithTasks,
  getSubmitButtonText,
}: Props) {
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
        {/* XXX Add autocompletion in text area */}
        <textarea
          className={cn(
            "flex-grow",
            "w-full",
            "border-4",
            "border-blue-200",
            "border-solid",
            "rounded-lg",
            "md:flex-grow-0",
            "md:h-64"
          )}
          autoFocus={true}
          value={rawTasks}
          onChange={(e) => setRawTasks(e.target.value)}
        ></textarea>

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
