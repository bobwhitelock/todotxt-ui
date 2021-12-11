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
  filePath: string;
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

// import React from "react";
// import { Helmet } from "react-helmet-async";

// import { useTasks } from "api";
// import { useQueryParams } from "queryParams";
// import { TasksGrid } from "components/TasksGrid";
// import { Tabs } from "components/Tabs";
// import { TasksToolbar } from "components/TasksToolbar";
// import {
//   incompleteTasks,
//   filterTasks,
//   pluralizeTasks,
//   todoFileBasename,
// } from "tasks";

// export function Root() {
//   const params = useQueryParams();

//   const { todoFiles } = useTasks();
//   const [title, setTitle] = React.useState<null | string>(null);

//   const tabConfigs = todoFiles.map((todoFile) => {
//     const fileName = todoFileBasename(todoFile);
//     return {
//       name: fileName,
//       content: <TasksGrid todoFile={todoFile} />,
//       subheader: <TasksToolbar todoFile={todoFile} />,
//       onSelect: () => {
//         const { tasks } = todoFile;
//         const filteredTasksCount = filterTasks({ tasks, params }).length;
//         const incompleteTasks_ = incompleteTasks(tasks);
//         const incompleteTasksCount = incompleteTasks_.length;
//         const taskOrTasks = pluralizeTasks(incompleteTasks_);

//         const tasksSummary =
//           filteredTasksCount === incompleteTasksCount
//             ? `${incompleteTasksCount} ${taskOrTasks}`
//             : `${filteredTasksCount}/${incompleteTasksCount} ${taskOrTasks}`;
//         setTitle(`${tasksSummary} | ${fileName}`);
//       },
//     };
//   });

//   return (
//     <>
//       <Helmet>
//         <title>{title}</title>
//       </Helmet>

//       <Tabs tabs={tabConfigs} />
//     </>
//   );
// }
// XXX Might need in `client/src/components/pages/TodoFile.tsx`, something like above
export function todoFileBasename(todoFile: TodoFile): string {
  return todoFile.filePath.split(/[\\/]/).pop() ?? "";
}

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
