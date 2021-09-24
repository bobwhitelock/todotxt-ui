import React from "react";
import { Helmet } from "react-helmet";

import { useTasks } from "api";
import { useQueryParams } from "queryParams";
import { TasksGrid } from "components/TasksGrid";
import { Tabs } from "components/Tabs";
import { TasksToolbar } from "components/TasksToolbar";
import {
  incompleteTasks,
  filterTasks,
  pluralizeTasks,
  todoFileBasename,
} from "tasks";

export function Root() {
  const params = useQueryParams();

  const { todoFiles } = useTasks();
  const [title, setTitle] = React.useState<null | string>(null);

  const tabConfigs = todoFiles.map((todoFile) => {
    const fileName = todoFileBasename(todoFile);
    return {
      name: fileName,
      content: <TasksGrid todoFile={todoFile} />,
      subheader: <TasksToolbar todoFile={todoFile} />,
      onSelect: () => {
        const { tasks } = todoFile;
        const filteredTasksCount = filterTasks({ tasks, params }).length;
        const incompleteTasks_ = incompleteTasks(tasks);
        const incompleteTasksCount = incompleteTasks_.length;
        const taskOrTasks = pluralizeTasks(incompleteTasks_);

        const tasksSummary =
          filteredTasksCount === incompleteTasksCount
            ? `${incompleteTasksCount} ${taskOrTasks}`
            : `${filteredTasksCount}/${incompleteTasksCount} ${taskOrTasks}`;
        setTitle(`${tasksSummary} | ${fileName}`);
      },
    };
  });

  return (
    <>
      <Helmet>
        <title>{title}</title>
      </Helmet>

      <Tabs tabs={tabConfigs} />
    </>
  );
}
