export type Meta = {
  csrfToken: string;
};

export type DeltaType =
  | "add"
  | "update"
  | "delete"
  | "complete"
  | "schedule"
  | "unschedule";

export type TagType = "project" | "context";
