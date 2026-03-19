import { parseMarkdownLines } from './markdownBlockParser'

export function renderMarkdownToRichEditor(
  controller: RichEditorController,
  markdown: string
): void {
  let lines = parseMarkdownLines(markdown)
  let i: number = 0
  while (i < lines.length) {
    let item = lines[i]
    controller.addTextSpan(item.text, {
      style: {
        fontSize: item.fontSize,
        fontColor: item.fontColor,
        fontWeight: item.fontWeight
      }
    })

    if (i !== lines.length - 1) {
      controller.addTextSpan('\n', {
        style: {
          fontSize: 18,
          fontColor: '#1F2329'
        }
      })
    }
    i += 1
  }
}
