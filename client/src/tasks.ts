import _ from "lodash";

import {
  AlwaysArrayParsedQuery,
  getContextParams,
  getProjectParams,
} from "queryParams";

const ALWAYS_AVAILABLE_CONTEXTS = [
  "@today",
  "@tomorrow",
  "@monday",
  "@tuesday",
  "@wednesday",
  "@thursday",
  "@friday",
  "@saturday",
  "@sunday",
];

export type TodoFile = {
  fileName: string;
  tasks: Task[];
};

export type Task = {
  raw: string;
  descriptionText: string;
  complete: boolean;
  priority: string | null;
  creationDate: string;
  completionDate: string;
  contexts: string[];
  projects: string[];
  metadata: { [key: string]: string | number };
};

export function taskIsToday(task: Task): boolean {
  return task.contexts.includes("@today");
}

export function sortTasks(tasks: Task[]): Task[] {
  return _.sortBy(tasks, [
    (task) => !taskIsToday(task),
    "metadata.due",
    "priority",
    "creationDate",
    "raw",
  ]);
}

export function incompleteTasks(tasks: Task[]): Task[] {
  return tasks.filter((task) => !task.complete);
}

export function filterTasks({
  tasks,
  params,
}: {
  tasks: Task[];
  params: AlwaysArrayParsedQuery;
}): Task[] {
  let filteredTasks = incompleteTasks(tasks);
  getContextParams(params).forEach((context) => {
    filteredTasks = filteredTasks.filter((t) => t.contexts.includes(context));
  });
  getProjectParams(params).forEach((project) => {
    filteredTasks = filteredTasks.filter((t) => t.projects.includes(project));
  });

  return filteredTasks;
}

export function pluralizeTasks(tasksOrIsPlural: Task[] | boolean): string {
  let isPlural;
  if (tasksOrIsPlural instanceof Array) {
    isPlural = tasksOrIsPlural.length !== 1;
  } else {
    isPlural = tasksOrIsPlural;
  }

  return isPlural ? "Tasks" : "Task";
}

export function availableContextsForTasks(tasks: Task[]): string[] {
  return _(tasks)
    .flatMap((task) => task.contexts)
    .concat(ALWAYS_AVAILABLE_CONTEXTS)
    .sortBy()
    .sortedUniq()
    .value();
}

export function availableProjectsForTasks(tasks: Task[]): string[] {
  return _(tasks)
    .flatMap((task) => task.projects)
    .sortBy()
    .sortedUniq()
    .value();
}
