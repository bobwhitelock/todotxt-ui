import cn from "classnames";
import { Link } from "react-router-dom";

import * as Icon from "components/Icon";
import * as urls from "urls";
import { IconButton } from "components/IconButton";
import { InlineMarkdown } from "components/InlineMarkdown";
import { TagPills } from "components/TagPills";
import { Task, taskIsToday } from "types";
import { useQueryParams, urlWithParams } from "queryParams";
import { useUpdateTasks } from "api";

type Props = {
  task: Task;
};

export function TaskCard({ task }: Props) {
  const classes = taskClasses(task);
  const params = useQueryParams();

  const scheduleTask = useUpdateTasks("schedule", [task.raw]);
  const unscheduleTask = useUpdateTasks("unschedule", [task.raw]);
  const deleteTask = useUpdateTasks("delete", [task.raw]);
  const completeTask = useUpdateTasks("complete", [task.raw]);

  return (
    <div
      className={cn(
        "card",
        "justify-between",
        "break-words",
        classes.border,
        classes.background
      )}
    >
      <div className="flex-grow">
        <div className="float-right px-1 py-2 text-gray-600">
          {Object.entries(task.metadata).map(([tag, value]) => (
            <span className="px-1" key={tag}>
              {tag}:{value}
            </span>
          ))}
          <span className={cn("font-semibold", classes.text)}>
            {task.priority}
          </span>
        </div>

        <div className="px-2 py-2">
          <p className="text-gray-900">
            <InlineMarkdown markdown={task.descriptionText} />
          </p>
        </div>

        <div className="px-2">
          <TagPills tagType="project" tags={task.projects} action="addFilter" />
          <TagPills tagType="context" tags={task.contexts} action="addFilter" />
        </div>
      </div>

      <div className="px-2 py-1 text-gray-600">{task.creationDate}</div>

      <div className="flex justify-between">
        {taskIsToday(task) ? (
          <IconButton
            onClick={unscheduleTask.eventHandler}
            disabled={unscheduleTask.mutation.isLoading}
          >
            <Icon.CalendarRemove
              backgroundClass="text-gray-500"
              foregroundClass="text-gray-600"
            />
          </IconButton>
        ) : (
          <IconButton
            onClick={scheduleTask.eventHandler}
            disabled={scheduleTask.mutation.isLoading}
          >
            <Icon.CalendarAdd
              backgroundClass="text-gray-500"
              foregroundClass="text-gray-600"
            />
          </IconButton>
        )}

        <IconButton
          onClick={(event) => {
            window.confirm("Are you sure you want to delete this task?") &&
              deleteTask.eventHandler(event);
          }}
          disabled={deleteTask.mutation.isLoading}
        >
          <Icon.Trash topClass="text-gray-600" bottomClass="text-gray-500" />
        </IconButton>

        <Link to={urlWithParams(urls.edit.forTask(task), params)}>
          <IconButton>
            <Icon.Edit topClass="text-gray-500" bottomClass="text-gray-600" />
          </IconButton>
        </Link>

        <IconButton
          onClick={completeTask.eventHandler}
          disabled={completeTask.mutation.isLoading}
        >
          <Icon.Check
            foregroundClass="text-green-600"
            backgroundClass="hidden"
          />
        </IconButton>
      </div>
    </div>
  );
}

function taskClasses(task: Task): {
  background: string;
  text: string;
  border: string;
} {
  let background = "bg-white";
  let text = "";
  let border = "";

  if (taskIsToday(task)) {
    border = "border-blue-300";
    background = "bg-blue-200";
  }

  switch (task.priority) {
    case "A":
      background = "bg-red-200";
      text = "text-red-600";
      break;
    case "B":
      background = "bg-orange-200";
      text = "text-orange-600";
      break;
    case "C":
      background = "bg-yellow-200";
      text = "text-yellow-600";
      break;
  }

  return { background, text, border };
}
