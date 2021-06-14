import { useState, useCallback } from "react";
import {
  defaultSuggestionsFilter,
  MentionData,
} from "@draft-js-plugins/mention";

import { MentionEditorPlugin } from "externalTypes";

type Props = {
  tags: string[];
  plugin: MentionEditorPlugin;
};

export function TagMentionSuggestions({ tags, plugin }: Props) {
  const { MentionSuggestions } = plugin;

  const mentions = toMentionsData(tags);
  const [suggestions, setSuggestions] = useState(mentions);

  const [open, setOpen] = useState(false);
  const onOpenChange = useCallback((_open: boolean) => {
    setOpen(_open);
  }, []);

  const onSearchChange = useCallback(
    ({ value }: { value: string }) => {
      setSuggestions(defaultSuggestionsFilter(value, mentions));
    },
    [mentions]
  );

  return (
    <MentionSuggestions
      open={open}
      onOpenChange={onOpenChange}
      suggestions={suggestions}
      onSearchChange={onSearchChange}
    />
  );
}

function toMentionsData(mentions: string[]): MentionData[] {
  return mentions.map((name) => ({ name }));
}
