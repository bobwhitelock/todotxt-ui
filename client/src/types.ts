export type Meta = {
  csrfToken: string;
};

export type Delta =
  | {
      type: "add" | "delete" | "complete" | "schedule" | "unschedule";
      arguments: { task: string };
    }
  | {
      type: "update";
      arguments: { task: string; newTask: string };
    };

export type TagType = "project" | "context";
