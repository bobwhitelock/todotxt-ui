import cn from "classnames";
import { Link } from "react-router-dom";

import {
  useQueryParams,
  urlWithParams,
  appendParamIfNotPresent,
  deleteParam,
} from "queryParams";
import { TagType, stripTagPrefix } from "types";

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

  const tagWithoutPrefix = stripTagPrefix(tag);
  const currentParams = useQueryParams();
  let linkParams = currentParams;
  if (action === "addFilter") {
    linkParams = appendParamIfNotPresent(
      currentParams,
      tagType,
      tagWithoutPrefix
    );
  } else if (action === "removeFilter") {
    linkParams = deleteParam(currentParams, tagType, tagWithoutPrefix);
  }

  const baseElement = <span className={cn("tag-pill", classes)}>{tag}</span>;

  if (linkParams === currentParams) {
    return baseElement;
  } else {
    return <Link to={urlWithParams("", linkParams)}>{baseElement}</Link>;
  }
}
