import _ from "lodash";
import queryString from "query-string";
import { useLocation } from "react-router";

import { addContextPrefix, addProjectPrefix } from "types";

type AlwaysArrayParsedQuery = {
  [key: string]: null | string[];
};

export function useQueryParams(): AlwaysArrayParsedQuery {
  const parsedQuery = queryString.parse(useLocation().search);
  return _.mapValues(parsedQuery, (value) => {
    if (value === null) {
      return [];
    } else {
      return _.castArray(value);
    }
  });
}

export function urlWithParams(
  url: string,
  params: AlwaysArrayParsedQuery
): string {
  return `${url}?${queryString.stringify(params)}`;
}

export function getContextParams(
  queryParams: AlwaysArrayParsedQuery
): string[] {
  return getParamValues(queryParams, "context").map(addContextPrefix);
}

export function getProjectParams(
  queryParams: AlwaysArrayParsedQuery
): string[] {
  return getParamValues(queryParams, "project").map(addProjectPrefix);
}

// Get all values for param with this name.
function getParamValues(
  queryParams: AlwaysArrayParsedQuery,
  name: string
): string[] {
  return queryParams[name] || [];
}

// Append a param with this name and value, if not already present.
export function appendParamIfNotPresent(
  queryParams: AlwaysArrayParsedQuery,
  name: string,
  value: string
): AlwaysArrayParsedQuery {
  const values = getParamValues(queryParams, name);

  if (values.includes(value)) {
    return queryParams;
  }

  const newQueryParams = _.cloneDeep(queryParams);
  newQueryParams[name] = [...values, value];
  return newQueryParams;
}

// Delete any params with this name and value.
export function deleteParam(
  queryParams: AlwaysArrayParsedQuery,
  name: string,
  value: string
): AlwaysArrayParsedQuery {
  const newQueryParams = _.cloneDeep(queryParams);
  const values = getParamValues(newQueryParams, name);
  newQueryParams[name] = values.filter((v) => v !== value);
  return newQueryParams;
}
