import React from "react";
import { Link } from "react-router-dom";

import * as Icon from "components/Icon";
import * as urls from "urls";
import { IconButton } from "components/IconButton";
import { TagPills } from "components/TagPills";
import {
  useQueryParams,
  urlWithParams,
  getContextParams,
  getProjectParams,
} from "queryParams";
import { TodoFile, incompleteTasks, filterTasks } from "tasks";

type Props = {
  todoFile: TodoFile;
};

export function TasksToolbar({ todoFile: { tasks } }: Props) {
  const params = useQueryParams();

  const contextFilters = getContextParams(params);
  const projectFilters = getProjectParams(params);
  const anyFilters = contextFilters.length !== 0 || projectFilters.length !== 0;

  const incompleteTasks_ = incompleteTasks(tasks);
  const filteredTasks = filterTasks({ tasks, params });

  const scrollToTop = (event: React.FormEvent<HTMLButtonElement>) => {
    event.preventDefault();
    window.scrollTo(0, 0);
  };

  const scrollToBottom = (event: React.FormEvent<HTMLButtonElement>) => {
    event.preventDefault();
    window.scrollTo(0, document.body.scrollHeight);
  };

  return (
    <div>
      <div className="py-2">
        {incompleteTasks_.length} tasks ({filteredTasks.length} shown)
      </div>

      <div className="flex-grow py-2">
        Filters:{" "}
        <TagPills
          tagType="project"
          tags={projectFilters}
          action="removeFilter"
        />
        <TagPills
          tagType="context"
          tags={contextFilters}
          action="removeFilter"
        />
        <span className="text-sm">
          {anyFilters ? (
            <Link to="?" className="text-blue-800 hover:opacity-50">
              Clear&nbsp;All
            </Link>
          ) : (
            "(None)"
          )}
        </span>
      </div>

      <div className="flex justify-between">
        {/* TODO Improve styling of these icons */}
        {/* Empty element so button gets flexed to right, and in consistent way to */}
        {/* buttons on other cards. */}
        <span></span>

        <IconButton onClick={scrollToTop} className="md:hidden">
          <Icon.ArrowThickUpCircle
            backgroundClass="text-gray-500"
            foregroundClass="text-gray-600"
          />
        </IconButton>

        <IconButton onClick={scrollToBottom} className="md:hidden">
          <Icon.ArrowThickDownCircle
            backgroundClass="text-gray-500"
            foregroundClass="text-gray-600"
          />
        </IconButton>

        <Link to={urlWithParams(urls.add, params)}>
          <IconButton>
            <Icon.AddSquare
              backgroundClass="text-green-300"
              foregroundClass="text-green-600"
            />
          </IconButton>
        </Link>
      </div>
    </div>
  );
}
