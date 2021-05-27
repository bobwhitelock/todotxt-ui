import {
  UseMutationResult,
  useQuery,
  useQueryClient,
  useMutation,
} from "react-query";

import { Task, DeltaType } from "types";

const TASKS_URL = "/api/tasks";
const TASKS_KEY = "tasks";

type TasksResponseData = { data: Task[] };

export type UpdateTasksMutationResult = UseMutationResult<
  TasksResponseData,
  unknown,
  void,
  unknown
>;

// XXX Add generic error handling - show alert or similar

export function useTasks() {
  return useQuery<TasksResponseData, Error>(TASKS_KEY, () =>
    fetch(TASKS_URL).then((response) => response.json())
  );
}

export function useUpdateTasks(
  deltaType: DeltaType,
  deltaArguments: string[]
): {
  mutation: UpdateTasksMutationResult;
  eventHandler: (event: React.SyntheticEvent) => void;
} {
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
