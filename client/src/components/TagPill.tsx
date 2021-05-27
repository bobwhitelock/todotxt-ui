import cn from "classnames";
import { Link } from "react-router-dom";

import {
  useQueryParams,
  urlWithParams,
  appendTagParam,
  deleteTagParam,
} from "queryParams";
import { TagType } from "types";

type Props = {
  tagType: TagType;
  tag: string;
  action: "addFilter" | "removeFilter";
};

export default function TagPill({ tagType, tag, action }: Props) {
  const classes = {
    project: "text-green-700 bg-green-100",
    context: "text-blue-700 bg-blue-100",
  }[tagType];

  const currentParams = useQueryParams();
  let linkParams = currentParams;
  if (action === "addFilter") {
    linkParams = appendTagParam(currentParams, tagType, tag);
  } else if (action === "removeFilter") {
    linkParams = deleteTagParam(currentParams, tagType, tag);
  }

  const baseElement = <span className={cn("tag-pill", classes)}>{tag}</span>;

  if (linkParams === currentParams) {
    return baseElement;
  } else {
    return <Link to={urlWithParams("", linkParams)}>{baseElement}</Link>;
  }
}
