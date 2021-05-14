import React from "react";
import cn from "classnames";

import * as Icon from "components/Icon";
import IconButton from "components/IconButton";
import { Task, isToday } from "types/Task";

type Props = {
  task: Task;
};

function TaskCard({ task }: Props) {
  const classes = taskClasses(task);

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
            {/* XXX Handle auto-linking here */}
            {task.description_text}
          </p>
        </div>

        <div className="px-2">
          {/* XXX Handle filtering via these pills */}
          <TagPills
            tags={task.projects}
            classes="text-green-700 bg-green-100"
          />
          <TagPills tags={task.contexts} classes="text-blue-700 bg-blue-100" />
        </div>
      </div>

      <div className="px-2 py-1 text-gray-600">{task.creation_date}</div>

      <div className="flex justify-between">
        {isToday(task) ? (
          <IconButton
            onClick={() => {
              "unschedule";
            }}
          >
            <Icon.CalendarRemove
              backgroundClass="text-gray-500"
              foregroundClass="text-gray-600"
            />
          </IconButton>
        ) : (
          <IconButton
            onClick={() => {
              "schedule";
            }}
          >
            <Icon.CalendarAdd
              backgroundClass="text-gray-500"
              foregroundClass="text-gray-600"
            />
          </IconButton>
        )}

        <IconButton
          onClick={() => {
            "delete";
          }}
          confirmMessage="Are you sure you want to delete this task?"
        >
          <Icon.Trash topClass="text-gray-600" bottomClass="text-gray-500" />
        </IconButton>

        <IconButton
          onClick={() => {
            "update";
          }}
        >
          <Icon.Edit topClass="text-gray-500" bottomClass="text-gray-600" />
        </IconButton>

        <IconButton
          onClick={() => {
            "complete";
          }}
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

function TagPills({ tags, classes }: { tags: string[]; classes: string }) {
  return (
    <>
      {tags.map((tag, index) => (
        <span className={cn("tag-pill", classes)} key={index}>
          {tag}
        </span>
      ))}
    </>
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

  if (isToday(task)) {
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

export default TaskCard;