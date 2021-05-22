import React from "react";
import cn from "classnames";

export default function IconButton({
  children,
  onClick,
  className,
  disabled,
}: {
  children: React.ReactNode;
  onClick?: (event: React.FormEvent<HTMLButtonElement>) => void;
  className?: string;
  disabled?: boolean;
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
        "disabled:opacity-50",
        "disabled:cursor-auto",
        className
      )}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
