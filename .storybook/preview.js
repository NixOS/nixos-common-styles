
export const parameters = {
  actions: {argTypesRegex: "^on[A-Z].*"},
  docs: {
    transformSource: (src, storyContext) => storyContext.storyFn().outerHTML,
  },
  options: {
    storySort: {
      order: [
        "Introduction",
        "Conventions",
      ],
    },
  },
}
