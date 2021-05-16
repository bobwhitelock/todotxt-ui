import React, { useState } from "react";
import cn from "classnames";
import { Redirect } from "react-router-dom";
import { useMutation } from "react-query";

import * as urls from "urls";

function Add() {
  const [rawTasks, setRawTasks] = useState("");
  const trimmedRawTasks = rawTasks.trim();
  const taskOrTasks =
    trimmedRawTasks.split("\n").length === 1 ? "Task" : "Tasks";

  // XXX Abstract this away and make generic
  // XXX Add generic error handling - show alert or similar
  const addTasks = useMutation((rawTasks: string) =>
    fetch("/api/tasks", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json;charset=UTF-8",
      },
      body: JSON.stringify({ type: "add", arguments: [rawTasks] }),
    })
  );

  const onSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    addTasks.mutate(rawTasks);
  };

  if (addTasks.isSuccess) {
    return <Redirect to={urls.root} />;
  }

  // TODO Debounce setting "Adding ..." text so this doesn't flash up very
  // briefly.
  const submitButtonText = addTasks.isLoading
    ? `Adding ${taskOrTasks}...`
    : `Add ${taskOrTasks}`;

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
        disabled={trimmedRawTasks === "" || addTasks.isLoading}
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

export default Add;
