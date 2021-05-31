import cn from "classnames";

type Props = {
  rawTasks: string;
  setRawTasks: (rawTasks: string) => void;
};

export function TaskEditor({ rawTasks, setRawTasks }: Props) {
  return (
    <textarea
      className={cn(
        "flex-grow",
        "w-full",
        "border-4",
        "border-blue-200",
        "border-solid",
        "rounded-lg",
        "md:flex-grow-0",
        "md:h-64"
      )}
      autoFocus={true}
      value={rawTasks}
      onChange={(e) => setRawTasks(e.target.value)}
    ></textarea>
  );
}
