import ReactDOM from "react-dom";
import { useMemo, useCallback, useRef, useEffect, useState } from "react";
import { Editor, Transforms, Range, createEditor, Descendant } from "slate";
import { withHistory } from "slate-history";
import {
  Slate,
  Editable,
  ReactEditor,
  withReact,
  useSelected,
  useFocused,
} from "slate-react";
import cn from "classnames";

import { useTasks } from "api";
import {
  Task,
  availableContextsForTasks,
  stripTagPrefix,
  partIsContext,
  partToString,
} from "types";
import { intersperse } from "utilities";

type MentionElement = {
  type: "mention";
  character: string;
  children: CustomText[];
};

type CustomText = {
  bold?: boolean;
  italic?: boolean;
  code?: boolean;
  text: string;
};

// @ts-expect-error
const Portal = ({ children }) => {
  return typeof document === "object"
    ? ReactDOM.createPortal(children, document.body)
    : null;
};

type Props = {
  currentTask: Task | undefined;
  setRawTasks: (rawTasks: string) => void;
  contexts: string[];
  projects: string[];
};

// XXX Remove all `ts-expect-error` in this file

export function TaskEditor({
  currentTask,
  setRawTasks,
  contexts,
  projects,
}: Props) {
  const ref = useRef<HTMLDivElement | null>();

  const [value, setValue] = useState<Descendant[]>([
    {
      // type: "paragraph",
      children: currentTask
        ? intersperse(
            currentTask.parsedDescription.map((part) => {
              if (partIsContext(part)) {
                return {
                  type: "mention",
                  character: stripTagPrefix(part.context),
                  children: [{ text: "" }],
                };
              } else {
                return { text: partToString(part) };
              }
            }),
            () => ({ text: " " })
          )
        : [{ text: "" }],
    },
  ]);

  const [target, setTarget] = useState<Range | undefined>();
  const [index, setIndex] = useState(0);
  const [search, setSearch] = useState("");
  const renderElement = useCallback((props) => <Element {...props} />, []);
  const editor = useMemo(
    // @ts-expect-error
    () => withMentions(withReact(withHistory(createEditor()))),
    []
  );

  const { tasks } = useTasks();
  const availableContexts = availableContextsForTasks(tasks);

  const contextSuggestions = availableContexts
    .map(stripTagPrefix)
    .filter((c) => c.toLowerCase().startsWith(search.toLowerCase()))
    .slice(0, 10);

  const onKeyDown = useCallback(
    (event) => {
      if (target) {
        switch (event.key) {
          case "ArrowDown":
            event.preventDefault();
            const prevIndex =
              index >= contextSuggestions.length - 1 ? 0 : index + 1;
            setIndex(prevIndex);
            break;
          case "ArrowUp":
            event.preventDefault();
            const nextIndex =
              index <= 0 ? contextSuggestions.length - 1 : index - 1;
            setIndex(nextIndex);
            break;
          case "Tab":
          case "Enter":
            event.preventDefault();
            Transforms.select(editor, target);
            insertMention(editor, contextSuggestions[index]);
            // @ts-expect-error
            setTarget(null);
            break;
          case "Escape":
            event.preventDefault();
            // @ts-expect-error
            setTarget(null);
            break;
        }
      }
    },
    [index, target, contextSuggestions, editor]
  );

  useEffect(() => {
    if (target && contextSuggestions.length > 0) {
      const el = ref.current;
      const domRange = ReactEditor.toDOMRange(editor, target);
      const rect = domRange.getBoundingClientRect();
      // @ts-expect-error
      el.style.top = `${rect.top + window.pageYOffset + 24}px`;
      // @ts-expect-error
      el.style.left = `${rect.left + window.pageXOffset}px`;
    }
  }, [contextSuggestions.length, editor, index, search, target]);

  return (
    <Slate
      editor={editor}
      value={value}
      onChange={(value) => {
        setValue(value);
        console.log("value [euyrjfzk]:", value); // eslint-disable-line no-console
        const { selection } = editor;

        if (selection && Range.isCollapsed(selection)) {
          const [start] = Range.edges(selection);
          const wordBefore = Editor.before(editor, start, { unit: "word" });
          const before = wordBefore && Editor.before(editor, wordBefore);
          const beforeRange = before && Editor.range(editor, before, start);
          const beforeText = beforeRange && Editor.string(editor, beforeRange);
          const beforeMatch = beforeText && beforeText.match(/^@(\w+)$/);
          const after = Editor.after(editor, start);
          const afterRange = Editor.range(editor, start, after);
          const afterText = Editor.string(editor, afterRange);
          const afterMatch = afterText.match(/^(\s|$)/);

          if (beforeMatch && afterMatch) {
            setTarget(beforeRange);
            setSearch(beforeMatch[1]);
            setIndex(0);
            return;
          }
        }

        // @ts-expect-error
        setTarget(null);
      }}
    >
      <Editable
        renderElement={renderElement}
        onKeyDown={onKeyDown}
        autoFocus={true}
        className={cn(
          "flex-grow",
          "w-full",
          "border-4",
          // isFocused ? "border-blue-300" : "border-blue-200",
          "border-blue-200",
          "focus:border-blue-300",
          "border-solid",
          "bg-white",
          "rounded-lg",
          "md:flex-grow-0",
          "md:h-64",
          "cursor-text"
        )}
      />
      {target && contextSuggestions.length > 0 && (
        <Portal>
          <div
            // @ts-expect-error
            ref={ref}
            style={{
              top: "-9999px",
              left: "-9999px",
              position: "absolute",
              zIndex: 1,
              padding: "3px",
              background: "white",
              borderRadius: "4px",
              boxShadow: "0 1px 5px rgba(0,0,0,.2)",
            }}
          >
            {contextSuggestions.map((char, i) => (
              <div
                key={char}
                style={{
                  padding: "1px 3px",
                  borderRadius: "3px",
                  background: i === index ? "#B4D5FF" : "transparent",
                }}
              >
                {char}
              </div>
            ))}
          </div>
        </Portal>
      )}
    </Slate>
  );
  // return (
  //   <textarea
  //     autoFocus={true}
  //     value={rawTasks}
  //     onChange={(e) => setRawTasks(e.target.value)}
  //   ></textarea>
  // );
}

// @ts-expect-error
const withMentions = (editor) => {
  const { isInline, isVoid } = editor;

  // @ts-expect-error
  editor.isInline = (element) => {
    return element.type === "mention" ? true : isInline(element);
  };

  // @ts-expect-error
  editor.isVoid = (element) => {
    return element.type === "mention" ? true : isVoid(element);
  };

  return editor;
};

// @ts-expect-error
const insertMention = (editor, character) => {
  const mention: MentionElement = {
    type: "mention",
    character,
    children: [{ text: "" }],
  };
  Transforms.insertNodes(editor, mention);
  Transforms.move(editor);
};

// @ts-expect-error
const Element = (props) => {
  const { attributes, children, element } = props;
  switch (element.type) {
    case "mention":
      return <Mention {...props} />;
    default:
      return <p {...attributes}>{children}</p>;
  }
};

// @ts-expect-error
const Mention = ({ attributes, children, element }) => {
  const selected = useSelected();
  const focused = useFocused();
  return (
    <span
      {...attributes}
      contentEditable={false}
      style={{
        padding: "3px 3px 2px",
        margin: "0 1px",
        verticalAlign: "baseline",
        display: "inline-block",
        borderRadius: "4px",
        backgroundColor: "#eee",
        fontSize: "0.9em",
        boxShadow: selected && focused ? "0 0 0 2px #B4D5FF" : "none",
      }}
    >
      @{element.character}
      {children}
    </span>
  );
};

const initialValue: Descendant[] = [
  {
    // @ts-expect-error
    type: "paragraph",
    children: [
      {
        text: "This example shows how you might implement a simple @-mentions feature that lets users autocomplete mentioning a user by their username. Which, in this case means Star Wars characters. The mentions are rendered as void inline elements inside the document.",
      },
    ],
  },
  {
    type: "paragraph",
    children: [
      { text: "Try mentioning characters, like " },
      {
        // @ts-expect-error
        type: "mention",
        character: "R2-D2",
        children: [{ text: "" }],
      },
      { text: " or " },
      {
        // @ts-expect-error
        type: "mention",
        character: "Mace Windu",
        children: [{ text: "" }],
      },
      { text: "!" },
    ],
  },
];
