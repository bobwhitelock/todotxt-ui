import { Task } from "types/Task";

export const root = "/";
export const add = "/add";
export const edit = {
  template: "/edit/:rawTask",
  forTask: (task: Task) => `/edit/${task.raw}`,
};
