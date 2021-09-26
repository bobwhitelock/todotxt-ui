import { useEffect } from "react";
import { useParams } from "react-router-dom";
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

export function useDecodedParams<
  Params extends { [K in keyof Params]?: string } = {}
>(): Params {
  let params = useParams<Params>();
  return _.mapValues(params, (param) =>
    decodeURIComponent(param ?? "")
  ) as Params;
}
