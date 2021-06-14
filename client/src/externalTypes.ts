import { ComponentType } from "react";
import { EditorPlugin } from "@draft-js-plugins/editor";
import { MentionSuggestionsPubProps } from "../../node_modules/@draft-js-plugins/mention/lib/MentionSuggestions/MentionSuggestions";

// From
// https://github.com/draft-js-plugins/draft-js-plugins/blob/9ae7348dfb492b13e349c7c5dc0869eb7ac72001/packages/mention/src/index.tsx#L84-L86.
// TODO Export this upstream so this is unnecessary.
export type MentionEditorPlugin = EditorPlugin & {
  MentionSuggestions: ComponentType<MentionSuggestionsPubProps>;
};
