import Markdown from "markdown-it";

type Props = {
  markdown: string;
};

export function InlineMarkdown({ markdown }: Props) {
  return (
    <span
      // Not actually dangerous since we control the source of `markdown`, and
      // we are only rendering a limited, non-dangerous subset of markdown
      // anyway.
      dangerouslySetInnerHTML={{
        __html: markdownRenderer.renderInline(markdown),
      }}
    ></span>
  );
}

const markdownRenderer = Markdown({ linkify: true });

// Inspired by example at
// https://github.com/markdown-it/markdown-it/blob/df4607f1d4d4be7fdc32e71c04109aea8cc373fa/docs/architecture.md#renderer.
const defaultLinkOpen =
  markdownRenderer.renderer.rules.link_open ||
  ((tokens, idx, options, _env, self) =>
    self.renderToken(tokens, idx, options));

markdownRenderer.renderer.rules.link_open = (
  tokens,
  idx,
  options,
  env,
  self
) => {
  const extraLinkAttrs: [string, string][] = [
    // These extra attributes should be added to every link.
    ["target", "_blank"],
    ["class", "underline"],
    ["rel", "noreferrer"],
  ];

  extraLinkAttrs.forEach((extraAttr) => {
    tokens[idx].attrPush(extraAttr);
  });

  return defaultLinkOpen(tokens, idx, options, env, self);
};
