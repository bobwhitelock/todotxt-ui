import { path } from "static-path";

import { Task, TodoFile } from "tasks";

type TodoFileParams = { todoFile: TodoFile };

export const root = path("/");
export const rootAdd = path("/add");

const _todoFile = path("/:todoFile");
// Custom function for todo file paths, so need to pass TodoFile rather than
// any string.
export const todoFile = ({ todoFile }: TodoFileParams) =>
  _todoFile({ todoFile: todoFile.fileName });
todoFile.pattern = _todoFile.pattern;
todoFile.parts = _todoFile.parts;
todoFile.path = _todoFile.path;

export const _todoFileAdd = todoFile.path("/add");
// Custom function for todo file paths, so need to pass TodoFile rather than
// any string.
export const todoFileAdd = ({ todoFile }: TodoFileParams) =>
  _todoFileAdd({ todoFile: todoFile.fileName });
todoFileAdd.pattern = _todoFileAdd.pattern;
todoFileAdd.parts = _todoFileAdd.parts;
todoFileAdd.path = _todoFileAdd.path;

const _todoFileEdit = todoFile.path("/edit/:rawTask");
// Custom function for edit path, so need to pass TodoFile and Task rather than
// strings; also performs necessary conversion.
// TODO: DRY all these custom functions up.
export const todoFileEdit = ({
  todoFile,
  task,
}: TodoFileParams & { task: Task }) =>
  _todoFileEdit({
    todoFile: todoFile.fileName,
    rawTask: encodeURIComponent(task.raw),
  });
todoFileEdit.pattern = _todoFileEdit.pattern;
todoFileEdit.parts = _todoFileEdit.parts;
todoFileEdit.path = _todoFileEdit.path;
