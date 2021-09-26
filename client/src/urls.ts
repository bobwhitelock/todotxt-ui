import { Task } from "types";

export const root = "/";
export const add = "/add";
export const edit = {
  template: "/edit/:rawTask",
  forTask: (task: Task) => `/edit/${encodeURIComponent(task.raw)}`,
};
