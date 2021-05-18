// All icons in this file come from Refactoring UI v1.0.2
// (https://refactoringui.com).

type LayeredIconProps = {
  foregroundClass: string;
  backgroundClass: string;
};

type TopAndBottomIconProps = {
  topClass: string;
  bottomClass: string;
};

export function AddSquare({
  backgroundClass,
  foregroundClass,
}: LayeredIconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      className="w-12 h-12 fill-current"
    >
      <rect
        width="18"
        height="18"
        x="3"
        y="3"
        rx="2"
        className={backgroundClass}
      />
      <path
        className={foregroundClass}
        d="M13 11h4a1 1 0 0 1 0 2h-4v4a1 1 0 0 1-2 0v-4H7a1 1 0 0 1 0-2h4V7a1 1 0 0 1 2 0v4z"
      />
    </svg>
  );
}

export function ArrowThickDownCircle({
  backgroundClass,
  foregroundClass,
}: LayeredIconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      className="w-12 h-12 fill-current"
    >
      <circle cx="12" cy="12" r="10" className={backgroundClass} />
      <path
        className={foregroundClass}
        d="M10 12V7a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v5h2a1 1 0 0 1 .7 1.7l-4 4a1 1 0 0 1-1.4 0l-4-4A1 1 0 0 1 8 12h2z"
      />
    </svg>
  );
}

export function ArrowThickUpCircle({
  backgroundClass,
  foregroundClass,
}: LayeredIconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      className="w-12 h-12 fill-current"
    >
      <circle cx="12" cy="12" r="10" className={backgroundClass} />
      <path
        className={foregroundClass}
        d="M14 12v5a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1v-5H8a1 1 0 0 1-.7-1.7l4-4a1 1 0 0 1 1.4 0l4 4A1 1 0 0 1 16 12h-2z"
      />
    </svg>
  );
}

export function CalendarAdd({
  backgroundClass,
  foregroundClass,
}: LayeredIconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      className="w-12 h-12 fill-current"
    >
      <path
        className={backgroundClass}
        d="M5 4h14a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6c0-1.1.9-2 2-2zm0 5v10h14V9H5z"
      />
      <path
        className={foregroundClass}
        d="M13 13h2a1 1 0 0 1 0 2h-2v2a1 1 0 0 1-2 0v-2H9a1 1 0 0 1 0-2h2v-2a1 1 0 0 1 2 0v2zM7 2a1 1 0 0 1 1 1v3a1 1 0 1 1-2 0V3a1 1 0 0 1 1-1zm10 0a1 1 0 0 1 1 1v3a1 1 0 0 1-2 0V3a1 1 0 0 1 1-1z"
      />
    </svg>
  );
}

export function CalendarRemove({
  backgroundClass,
  foregroundClass,
}: LayeredIconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      className="w-12 h-12 fill-current"
    >
      <path
        className={backgroundClass}
        d="M5 4h14a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6c0-1.1.9-2 2-2zm0 5v10h14V9H5z"
      />
      <path
        className={foregroundClass}
        d="M7 2a1 1 0 0 1 1 1v3a1 1 0 1 1-2 0V3a1 1 0 0 1 1-1zm10 0a1 1 0 0 1 1 1v3a1 1 0 0 1-2 0V3a1 1 0 0 1 1-1zm-2 13H9a1 1 0 0 1 0-2h6a1 1 0 0 1 0 2z"
      />
    </svg>
  );
}

export function Check({ backgroundClass, foregroundClass }: LayeredIconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      className="w-12 h-12 text-green-600 fill-current"
    >
      <circle cx="12" cy="12" r="10" className={backgroundClass} />
      <path
        d="M10 14.59l6.3-6.3a1 1 0 0 1 1.4 1.42l-7 7a1 1 0 0 1-1.4 0l-3-3a1 1 0 0 1 1.4-1.42l2.3 2.3z"
        className={foregroundClass}
      />
    </svg>
  );
}

export function Edit({ topClass, bottomClass }: TopAndBottomIconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      className="w-12 h-12 fill-current"
    >
      <path
        className={topClass}
        d="M4 14a1 1 0 0 1 .3-.7l11-11a1 1 0 0 1 1.4 0l3 3a1 1 0 0 1 0 1.4l-11 11a1 1 0 0 1-.7.3H5a1 1 0 0 1-1-1v-3z"
      />
      <rect width="20" height="2" x="2" y="20" className={bottomClass} rx="1" />
    </svg>
  );
}

export function Trash({ topClass, bottomClass }: TopAndBottomIconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      className="w-12 h-12 fill-current"
    >
      <path
        className={bottomClass}
        d="M5 5h14l-.89 15.12a2 2 0 0 1-2 1.88H7.9a2 2 0 0 1-2-1.88L5 5zm5 5a1 1 0 0 0-1 1v6a1 1 0 0 0 2 0v-6a1 1 0 0 0-1-1zm4 0a1 1 0 0 0-1 1v6a1 1 0 0 0 2 0v-6a1 1 0 0 0-1-1z"
      />
      <path
        className={topClass}
        d="M8.59 4l1.7-1.7A1 1 0 0 1 11 2h2a1 1 0 0 1 .7.3L15.42 4H19a1 1 0 0 1 0 2H5a1 1 0 1 1 0-2h3.59z"
      />
    </svg>
  );
}
