import cn from "classnames";
import { Editor, EditorState, ContentState } from "draft-js";
import { useState, useRef, useEffect } from "react";

type Props = {
  rawTasks: string;
  setRawTasks: (rawTasks: string) => void;
};

export function TaskEditor({ rawTasks, setRawTasks }: Props) {
  const [editorState, setEditorState] = useState(() =>
    EditorState.moveFocusToEnd(
      EditorState.createWithContent(ContentState.createFromText(rawTasks))
    )
  );

  const editor = useRef<Editor>(null);
  const focusEditor = () => editor?.current?.focus();
  // Auto-focus editor on mount.
  useEffect(focusEditor, []);
  const [isFocused, setIsFocused] = useState(true);

  return (
    <div
      onClick={focusEditor}
      className={cn(
        "flex-grow",
        "w-full",
        "border-4",
        isFocused ? "border-blue-300" : "border-blue-200",
        "border-solid",
        "bg-white",
        "rounded-lg",
        "md:flex-grow-0",
        "md:h-64",
        "cursor-text"
      )}
    >
      <Editor
        ref={editor}
        editorState={editorState}
        onChange={(state) => {
          setEditorState(state);
          setRawTasks(state.getCurrentContent().getPlainText());
        }}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
      />
    </div>
  );
}
