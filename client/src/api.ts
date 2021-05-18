import { useQuery, useMutation } from "react-query";

import { Task } from "types/Task";
import { DeltaType } from "types/DeltaType";

const TASKS_URL = "/api/tasks";

// XXX Add generic error handling - show alert or similar

export function useTasks() {
  return useQuery<{ data: Task[] }, Error>("tasks", () =>
    fetch(TASKS_URL).then((response) => response.json())
  );
}

export function useUpdateTasks(deltaType: DeltaType, deltaArguments: string[]) {
  const mutation = useMutation(() =>
    fetch(TASKS_URL, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json;charset=UTF-8",
      },
      body: JSON.stringify({ type: deltaType, arguments: deltaArguments }),
    })
  );

  const eventHandler = (event: React.SyntheticEvent) => {
    event.preventDefault();
    mutation.mutate();
  };

  return { mutation, eventHandler };
}
