import { useQuery, useQueryClient, useMutation } from "react-query";

import { Task } from "types/Task";
import { DeltaType } from "types/DeltaType";

const TASKS_URL = "/api/tasks";
const TASKS_KEY = "tasks";

// XXX Add generic error handling - show alert or similar

export function useTasks() {
  return useQuery<{ data: Task[] }, Error>(TASKS_KEY, () =>
    fetch(TASKS_URL).then((response) => response.json())
  );
}

export function useUpdateTasks(deltaType: DeltaType, deltaArguments: string[]) {
  const queryClient = useQueryClient();

  const updateTasks = () =>
    fetch(TASKS_URL, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json;charset=UTF-8",
      },
      body: JSON.stringify({ type: deltaType, arguments: deltaArguments }),
    }).then((response) => response.json());

  const mutation = useMutation(updateTasks, {
    onSuccess: (data) => queryClient.setQueryData(TASKS_KEY, data),
  });

  const eventHandler = (event: React.SyntheticEvent) => {
    event.preventDefault();
    mutation.mutate();
  };

  return { mutation, eventHandler };
}
