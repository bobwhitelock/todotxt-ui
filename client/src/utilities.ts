export function stripTagPrefix(tag: string) {
  return tag.replace(/^[@+]/, "");
}
