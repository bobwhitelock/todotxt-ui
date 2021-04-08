import React from "react";
import cn from "classnames";

function Add() {
  return (
    <form className="container flex flex-col h-screen px-4 py-6 mx-auto">
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
      ></textarea>

      <input
        type="submit"
        value="Add Tasks"
        className={cn(
          "w-full",
          "py-3",
          "mt-3",
          "mb-16",
          "rounded-lg",
          "text-white",
          "bg-green-600",
          "hover:bg-green-800",
          "focus:bg-green-800",
          "font-bold",
          "cursor-pointer",
          "disabled:bg-green-600",
          "disabled:opacity-75",
          "disabled:cursor-auto"
        )}
      />
    </form>
  );
}

export default Add;
