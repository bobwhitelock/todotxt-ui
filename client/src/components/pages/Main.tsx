import React from "react";
import { Link } from "react-router-dom";
import { useQuery } from "react-query";

import * as Icon from "components/Icon";
import * as urls from "urls";
import IconButton from "components/IconButton";
import TaskCard from "components/TaskCard";
import { Task } from "types/Task";

function Main() {
  // XXX Handle isLoading and error
  // XXX Have this return Task[]
  const { isLoading, error, data } = useQuery("tasks", () =>
    fetch("/api/tasks").then((response) => response.json())
  );
  const allTasks: Task[] = data ? data.data : [];
  // XXX handle filtering
  // XXX Filter out complete tasks
  // XXX handle sorting tasks to be shown
  const filters: null[] = [];
  const filteredTasks = allTasks;

  return (
    <div className="flex flex-wrap text-lg">
      <div className="sticky top-0 bg-gray-300 card md:static">
        <div className="py-2">
          {allTasks.length} tasks ({filteredTasks.length} shown)
        </div>
        <div className="flex-grow py-2">
          {/* XXX Do this better */}
          {filters && <Filters filters={filters} />}
        </div>

        <div className="flex justify-between">
          {/* TODO Improve styling of these icons */}
          {/* Empty element so button gets flexed to right, and in consistent way to */}
          {/* buttons on other cards. */}
          <span></span>

          <IconButton
            onClick={() => window.scrollTo(0, 0)}
            className="md:hidden"
          >
            <Icon.ArrowThickUpCircle
              backgroundClass="text-gray-500"
              foregroundClass="text-gray-600"
            />
          </IconButton>

          <IconButton
            onClick={() => window.scrollTo(0, document.body.scrollHeight)}
            className="md:hidden"
          >
            <Icon.ArrowThickDownCircle
              backgroundClass="text-gray-500"
              foregroundClass="text-gray-600"
            />
          </IconButton>

          <Link to={urls.add}>
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
        // XXX Better index than this? Need to generate and send ID from server?
        <TaskCard task={task} key={`${index}:${task.raw}`} />
      ))}
    </div>
  );
}

function Filters({ filters }: { filters: null[] }) {
  // XXX add rest here
  return (
    <>
      Filters:
      {filters.map((filter) => (
        <FilterPill filter={filter} />
      ))}
    </>
  );
}

function FilterPill({ filter }: { filter: null }) {
  return filter;
}

export default Main;
