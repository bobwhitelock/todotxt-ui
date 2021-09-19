import {
  UseMutationResult,
  useQuery,
  useQueryClient,
  useMutation,
} from "react-query";

import { Meta, TodoFile, DeltaType, sortTasks } from "types";

const TASKS_URL = "/api/tasks";
const TASKS_KEY = "tasks";

type TasksResponseData = { data: TodoFile[] };

type MetaResponseData = { data: Meta };

export type UpdateTasksMutationResult = UseMutationResult<
  TasksResponseData,
  unknown,
  void,
  unknown
>;

function useMeta() {
  const { data, ...rest } = useQuery<MetaResponseData, Error>(
    "meta",
    () => fetch("/api/meta").then((response) => response.json()),
    {
      // Should only need to fetch this once, so minimize refetching.
      refetchOnMount: false,
      refetchOnWindowFocus: false,
      refetchOnReconnect: false,
    }
  );
  const meta = data ? data.data : null;
  return { meta, ...rest };
}

export function useTasks() {
  const { data, ...rest } = useQuery<TasksResponseData, Error>(TASKS_KEY, () =>
    fetch(TASKS_URL).then((response) => response.json())
  );
  const todoFiles = data
    ? data.data.map((tf) => ({ ...tf, tasks: sortTasks(tf.tasks) }))
    : [];
  return { todoFiles, ...rest };
}

export function useUpdateTasks(
  deltaType: DeltaType,
  deltaArguments: string[]
): {
  mutation: UpdateTasksMutationResult;
  eventHandler: (event: React.SyntheticEvent) => void;
} {
  const { meta } = useMeta();
  const queryClient = useQueryClient();

  const updateTasks = () =>
    fetch(TASKS_URL, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json;charset=UTF-8",
        "X-CSRF-TOKEN": meta?.csrfToken || "",
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
