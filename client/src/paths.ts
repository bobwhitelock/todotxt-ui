import { path } from "static-path";

import { Task } from "tasks";

export const root = path("/");
export const add = path("/add");

const _edit = path("/edit/:rawTask");
// Custom function for edit path, accepting more specific argument and
// performing necessary conversion.
export const edit = ({ task }: { task: Task }) =>
  _edit({ rawTask: encodeURIComponent(task.raw) });
edit.pattern = _edit.pattern;
edit.parts = _edit.parts;
edit.path = _edit.path;
