import { useEffect } from "react";
import { Params, useParams } from "react-router-dom";
import _ from "lodash";

// See https://stackoverflow.com/a/821227/2620402.
export function useNavigationWarning(shouldShow: boolean) {
  useEffect(() => {
    const enableNavigationWarning = () => {
      window.onbeforeunload = () => "";
    };

    const disableNavigationWarning = () => {
      window.onbeforeunload = () => null;
    };

    shouldShow ? enableNavigationWarning() : disableNavigationWarning();
    return disableNavigationWarning;
  }, [shouldShow]);
}

// Same type signature as `useParams` in `react-router`
// (https://github.com/remix-run/react-router/blob/d02f13cff0b0a5470be994d7b79c26635bb62e5a/packages/react-router/index.tsx#L529-L531).
export function useDecodedParams<Key extends string = string>(): Readonly<
  Params<Key>
> {
  let params = useParams<Key>();
  return _.mapValues(params, (param) => decodeURIComponent(param ?? ""));
}
