import { TagPill } from "components/TagPill";

import { TagType } from "types";

type Props = {
  tagType: TagType;
  tags: string[];
  action: "addFilter" | "removeFilter";
};

export function TagPills({ tagType, tags, action }: Props) {
  return (
    <>
      {tags.map((tag, index) => (
        <TagPill tagType={tagType} tag={tag} action={action} key={index} />
      ))}
    </>
  );
}
