import React, { useState } from "react";
import cn from "classnames";
import { useParams, Redirect } from "react-router-dom";

import * as urls from "urls";
import { useUpdateTasks } from "api";

// XXX DRY up this and Add

function Edit() {
  const { rawTask: originalRawTask } = useParams<{ rawTask: string }>();
  const [rawTasks, setRawTasks] = useState(originalRawTask);
  const trimmedRawTasks = rawTasks.trim();

  const { mutation: editTask, eventHandler: onSubmit } = useUpdateTasks(
    "update",
    [originalRawTask, rawTasks]
  );

  if (editTask.isSuccess) {
    return <Redirect to={urls.root} />;
  }

  // TODO Debounce setting "Updating ..." text so this doesn't flash up very
  // briefly.
  const submitButtonText = editTask.isLoading
    ? "Updating Task..."
    : "Update Task";

  return (
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
          trimmedRawTasks === originalRawTask ||
          editTask.isLoading
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
  );
}

export default Edit;
