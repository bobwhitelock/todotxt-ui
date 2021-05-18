import _ from "lodash";

export type Task = {
  raw: string;
  description_text: string;
  complete: boolean;
  priority: string | null;
  // XXX Handle these as dates
  creation_date: string;
  completion_date: string;
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
    "creation_date",
    "raw",
  ]);
}
