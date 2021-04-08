import React from "react";
import cn from "classnames";

export default function IconButton({
  children,
  onClick,
  className,
  // XXX Actually use this / use in callback and don't pass here
  confirmMessage,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  className?: string;
  confirmMessage?: string;
}) {
  return (
    <button
      className={cn(
        "rounded",
        "px-1",
        "pb-1",
        "inline-block",
        "hover:opacity-50",
        "focus:opacity-50",
        "focus:shadow-outline",
        className
      )}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
