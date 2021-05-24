import React from "react";
import { Link } from "react-router-dom";

import * as Icon from "components/Icon";
import * as urls from "urls";
import IconButton from "components/IconButton";
import TaskCard from "components/TaskCard";
import { useTasks } from "api";
import { sorted } from "types/Task";

export default function Root() {
  // XXX Handle isLoading and error
  const { isLoading, error, data } = useTasks();
  const allTasks = sorted(data ? data.data : []);
  const incompleteTasks = allTasks.filter((task) => !task.complete);

  // XXX handle filtering
  const filters: null[] = [];
  const filteredTasks = incompleteTasks;

  const scrollToTop = (event: React.FormEvent<HTMLButtonElement>) => {
    event.preventDefault();
    window.scrollTo(0, 0);
  };

  const scrollToBottom = (event: React.FormEvent<HTMLButtonElement>) => {
    event.preventDefault();
    window.scrollTo(0, document.body.scrollHeight);
  };

  return (
    <div className="flex flex-wrap text-lg">
      <div className="sticky top-0 bg-gray-300 card md:static">
        <div className="py-2">
          {incompleteTasks.length} tasks ({filteredTasks.length} shown)
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
