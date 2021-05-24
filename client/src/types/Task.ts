import _ from "lodash";

export type TagType = "project" | "context";

export type Task = {
  raw: string;
  descriptionText: string;
  complete: boolean;
  priority: string | null;
  // XXX Handle these as dates
  creationDate: string;
  completionDate: string;
  contexts: string[];
  projects: string[];
  metadata: { [key: string]: string | number };
};

export function isToday(task: Task): boolean {
  return task.contexts.includes("@today");
}

export function sorted(tasks: Task[]): Task[] {
  return _.sortBy(tasks, [
    (task) => !isToday(task),
    "metadata.due",
    "priority",
    "creationDate",
    "raw",
  ]);
}

export function stripPrefix(tag: string) {
  return tag.replace(/^[@+]/, "");
}

export function addContextPrefix(tagWithoutPrefix: string): string {
  return "@" + tagWithoutPrefix;
}

export function addProjectPrefix(tagWithoutPrefix: string): string {
  return "+" + tagWithoutPrefix;
}
