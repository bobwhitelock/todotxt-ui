export type Meta = {
  csrfToken: string;
};

export type Delta =
  | {
      type: "add" | "delete" | "complete" | "schedule" | "unschedule";
      arguments: { task: string; file: string };
    }
  | {
      type: "update";
      arguments: { task: string; newTask: string; file: string };
    };

export type TagType = "project" | "context";
