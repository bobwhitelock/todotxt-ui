import { TaskCard } from "components/TaskCard";
import { useQueryParams } from "queryParams";
import { TodoFile, filterTasks } from "tasks";

type Props = {
  todoFile: TodoFile;
};

export function TasksGrid({ todoFile }: Props) {
  const { tasks } = todoFile;
  const params = useQueryParams();
  const filteredTasks = filterTasks({ tasks, params });

  return (
    <div className="flex flex-wrap text-lg">
      {filteredTasks.map((task, index) => (
        <TaskCard
          todoFile={todoFile}
          task={task}
          key={`${index}:${task.raw}`}
        />
      ))}
    </div>
  );
}
