import { useEffect } from "react";

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
