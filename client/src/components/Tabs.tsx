import React, { ReactNode } from "react";
import cn from "classnames";
import _ from "lodash";

type Props = {
  tabs: TabConfig[];
};

type TabConfig = {
  name: string;
  content: ReactNode;
  subheader: ReactNode;
  onSelect: () => void;
};

// Component adapted from
// https://www.creative-tim.com/learning-lab/tailwind-starter-kit/documentation/react/tabs/text.
export function Tabs({ tabs }: Props) {
  const firstTab = tabs[0];

  const [openTab, setOpenTab] = React.useState<string | null>(null);
  if (!openTab && firstTab) {
    // Set the first open tab, once there are any tabs to select.
    setOpenTab(firstTab.name);
  }

  const openTabConfig = _.find(tabs, (tab) => tab.name === openTab);
  React.useEffect(() => {
    openTabConfig && openTabConfig.onSelect();
  }, [openTabConfig]);

  if (!firstTab) {
    return <span>Loading...</span>;
  }

  const isOpen = (tab: TabConfig) => openTab === tab.name;

  return (
    <>
      <div className="flex flex-wrap">
        <div className="w-full">
          <div className="sticky md:static top-0 bg-gray-300 border-b-2 border-gray-400 p-2">
            <ul
              className="flex flex-row flex-wrap mb-0 list-none"
              role="tablist"
            >
              {tabs.map((tab) => (
                <li
                  key={tab.name}
                  className="flex-auto pt-1 pb-2 mr-2 -mb-px text-center last:mr-0"
                >
                  <button
                    className={cn([
                      "text-xs",
                      "font-bold",
                      "uppercase",
                      "px-5",
                      "py-3",
                      "shadow-lg",
                      "rounded",
                      "block",
                      "leading-normal",
                      "w-full",
                      isOpen(tab)
                        ? "text-white bg-green-600"
                        : "text-green-600 bg-white",
                    ])}
                    onClick={() => {
                      setOpenTab(tab.name);
                    }}
                    data-toggle="tab"
                    role="tablist"
                  >
                    {tab.name}
                  </button>
                </li>
              ))}
            </ul>

            {tabs.map((tab) => (
              <div key={tab.name} className={isOpen(tab) ? "block" : "hidden"}>
                {tab.subheader}
              </div>
            ))}
          </div>

          <div className="flex flex-col w-full min-w-0 mb-6 break-words bg-white rounded shadow-lg">
            <div className="flex-auto">
              <div className="tab-content tab-space">
                {tabs.map((tab) => (
                  <div
                    key={tab.name}
                    className={isOpen(tab) ? "block" : "hidden"}
                  >
                    {tab.content}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
