import _ from "lodash";

// TODO Make these configurable - see
// https://github.com/bobwhitelock/todotxt-ui/issues/122.
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

export type DeltaType =
  | "add"
  | "update"
  | "delete"
  | "complete"
  | "schedule"
  | "unschedule";

export type TagType = "project" | "context";

type Text = { text: string };
type Context = { context: string };
type Project = { project: string };
type Metadatum = { metadatum: { key: string; value: number | string } };

type DescriptionPart = Text | Context | Project | Metadatum;

export type Task = {
  raw: string;
  descriptionText: string;
  parsedDescription: DescriptionPart[];
  complete: boolean;
  priority: string | null;
  // XXX Handle these as dates
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

export function stripTagPrefix(tag: string): string {
  return tag.replace(/^[@+]/, "");
}

export function partIsText(part: DescriptionPart): part is Text {
  return (part as Text).text !== undefined;
}

export function partIsContext(part: DescriptionPart): part is Context {
  return (part as Context).context !== undefined;
}

export function partIsProject(part: DescriptionPart): part is Project {
  return (part as Project).project !== undefined;
}

export function partIsMetadatum(part: DescriptionPart): part is Metadatum {
  return (part as Metadatum).metadatum !== undefined;
}

export function partToString(part: DescriptionPart): string {
  if (partIsText(part)) {
    return part.text;
  }

  if (partIsContext(part)) {
    return part.context;
  }

  if (partIsProject(part)) {
    return part.project;
  }

  if (partIsMetadatum(part)) {
    const { key, value } = part.metadatum;
    return `${key}:${value}`;
  }

  throw new Error(`Unhandled DescriptionPart type: ${part}`);
}
