import cn from "classnames";
import createMentionPlugin from "@draft-js-plugins/mention";
import Editor from "@draft-js-plugins/editor";
import { EditorState, ContentState } from "draft-js";
import { useState, useRef, useEffect } from "react";

import { TagMentionSuggestions } from "components/TagMentionSuggestions";
import { availableContextsForTasks, availableProjectsForTasks } from "types";
import { useTasks } from "api";

const contextMentionPlugin = createMentionPlugin({});
const projectMentionPlugin = createMentionPlugin({ mentionTrigger: "+" });

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

  // XXX Need to handle isLoading and error, and/or DRY up more with
  // `client/src/components/pages/Root.tsx`
  const { data } = useTasks();
  const tasks = data ? data.data : [];

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
        plugins={[contextMentionPlugin, projectMentionPlugin]}
        onChange={(state) => {
          setEditorState(state);
          setRawTasks(state.getCurrentContent().getPlainText());
        }}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
      />
      <TagMentionSuggestions
        tags={availableContextsForTasks(tasks)}
        plugin={contextMentionPlugin}
      />
      <TagMentionSuggestions
        tags={availableProjectsForTasks(tasks)}
        plugin={projectMentionPlugin}
      />
    </div>
  );
}
