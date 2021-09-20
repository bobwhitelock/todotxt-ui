import { useState, useRef, useEffect } from "react";
import cn from "classnames";
import { Navigate } from "react-router-dom";
import { Helmet } from "react-helmet-async";
import _ from "lodash";
import Tribute from "tributejs";
import { DateTime } from "luxon";
import "../../node_modules/tributejs/dist/tribute.css";

import * as urls from "urls";
import { UpdateTasksMutationResult, useTasks } from "api";
import { useQueryParams, urlWithParams } from "queryParams";
import { availableContextsForTasks, availableProjectsForTasks } from "tasks";
import { stripTagPrefix } from "utilities";
import { useNavigationWarning } from "hooks";

const TRIBUTE_REPLACED_EVENT = "tribute-replaced";

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

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const { todoFiles } = useTasks();
  // XXX Just use first todo file for now.
  const tasks = todoFiles[0] ? todoFiles[0].tasks : [];

  // This dance is needed so `useEffect` below doesn't continuously rerun
  // (which makes it impossible to interact with the Tribute autocomplete),
  // because reference to `tasks` above keeps changing despite actual tasks
  // staying the same. See
  // https://www.benmvp.com/blog/object-array-dependencies-react-useEffect-hook/#option-4---do-it-yourself.
  const tasksRef = useRef(tasks);
  if (!_.isEqual(tasksRef.current, tasks)) {
    tasksRef.current = tasks;
  }

  const tributeEventListener = () => {
    const current = textareaRef.current;
    current && setRawTasks(current.value);
  };

  useEffect(() => {
    const current = textareaRef.current;
    if (!current) {
      return;
    }

    const tasks = tasksRef.current;
    const projects = availableProjectsForTasks(tasks).map(stripTagPrefix);
    const contexts = availableContextsForTasks(tasks).map(stripTagPrefix);

    const tribute = new Tribute({
      collection: [
        { values: toTributeValues(projects), trigger: "+" },
        { values: toTributeValues(contexts), trigger: "@" },
        {
          values: dateSuggestionsForTribute(),
          trigger: "due:",
        },
      ],
      noMatchTemplate: () => '<span class:"hidden"></span>',
      spaceSelectsMatch: true,
    });

    tribute.attach(current);

    // Needed otherwise React doesn't know Tribute has updated the textarea
    // content on autocompletion.
    current.addEventListener(TRIBUTE_REPLACED_EVENT, tributeEventListener);

    return () => {
      if (!current) {
        return;
      }
      tribute.detach(current);
      current.removeEventListener(TRIBUTE_REPLACED_EVENT, tributeEventListener);
    };
  }, [textareaRef, tasksRef]);

  const formIsClean =
    trimmedRawTasks === "" || trimmedRawTasks === initialRawTask;

  useNavigationWarning(!formIsClean);

  const params = useQueryParams();
  if (mutation.isSuccess) {
    return <Navigate to={urlWithParams(urls.root, params)} />;
  }

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
        <textarea
          ref={textareaRef}
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
          disabled={formIsClean || mutation.isLoading}
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

function toTributeValues(array: string[]) {
  return array.map((i) => ({ key: i, value: i }));
}

function dateSuggestionsForTribute() {
  const dateSuggestions: [
    string,
    Partial<Record<"days" | "weeks" | "months", number>>
  ][] = [
    ["today", {}],
    ["tomorrow", { days: 1 }],
    ["day after tomorrow", { days: 2 }],
    ["1 week", { weeks: 1 }],
    ["2 weeks", { weeks: 2 }],
    ["1 month", { months: 1 }],
  ];

  const today = DateTime.local();
  return dateSuggestions.map(([description, dateDelta]) => {
    const isoDate = today.plus(dateDelta).toISODate();
    return {
      key: `${description} (${isoDate})`,
      value: isoDate,
    };
  });
}
