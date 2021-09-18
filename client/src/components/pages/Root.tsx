import React from "react";
import { Link } from "react-router-dom";
import { Helmet } from "react-helmet";

import * as Icon from "components/Icon";
import * as urls from "urls";
import { IconButton } from "components/IconButton";
import { TaskCard } from "components/TaskCard";
import { TagPills } from "components/TagPills";
import { useTasks } from "api";
import {
  useQueryParams,
  urlWithParams,
  getContextParams,
  getProjectParams,
} from "queryParams";
import { pluralizeTasks } from "types";

export function Root() {
  const { tasks } = useTasks();
  const incompleteTasks = tasks.filter((task) => !task.complete);

  const params = useQueryParams();
  const contextFilters: string[] = getContextParams(params);
  const projectFilters: string[] = getProjectParams(params);

  let filteredTasks = incompleteTasks;
  contextFilters.forEach((context) => {
    filteredTasks = filteredTasks.filter((t) => t.contexts.includes(context));
  });
  projectFilters.forEach((project) => {
    filteredTasks = filteredTasks.filter((t) => t.projects.includes(project));
  });

  const anyFilters = contextFilters.length !== 0 || projectFilters.length !== 0;

  const scrollToTop = (event: React.FormEvent<HTMLButtonElement>) => {
    event.preventDefault();
    window.scrollTo(0, 0);
  };

  const scrollToBottom = (event: React.FormEvent<HTMLButtonElement>) => {
    event.preventDefault();
    window.scrollTo(0, document.body.scrollHeight);
  };

  const filteredTasksCount = filteredTasks.length;
  const incompleteTasksCount = incompleteTasks.length;
  const taskOrTasks = pluralizeTasks(incompleteTasks);
  const title =
    filteredTasksCount === incompleteTasksCount
      ? `${incompleteTasksCount} ${taskOrTasks}`
      : `${filteredTasksCount}/${incompleteTasksCount} ${taskOrTasks}`;

  return (
    <>
      <Helmet>
        <title>{title}</title>
      </Helmet>

      <div className="flex flex-wrap text-lg">
        <div className="sticky top-0 bg-gray-300 card md:static">
          <div className="py-2">
            {incompleteTasks.length} tasks ({filteredTasks.length} shown)
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

        {filteredTasks.map((task, index) => (
          <TaskCard task={task} key={`${index}:${task.raw}`} />
        ))}
      </div>
    </>
  );
}
