import { Task } from "tasks";

export const root = "/";
export const add = "/add";
export const edit = {
  template: "/edit/:rawTask",
  forTask: (task: Task) => `/edit/${encodeURIComponent(task.raw)}`,
};
