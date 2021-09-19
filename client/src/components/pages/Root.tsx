import { useTasks } from "api";
import { TasksGrid } from "components/TasksGrid";
import { Tabs } from "components/Tabs";

export function Root() {
  const { todoFiles } = useTasks();

  const tabConfigs = todoFiles.map((todoFile) => {
    return {
      name: todoFile.fileName,
      content: <TasksGrid todoFile={todoFile} />,
    };
  });

  return <Tabs tabs={tabConfigs} />;
}
