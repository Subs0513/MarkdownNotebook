import { MarkdownLineNode } from '../models/MarkdownNode'

export function parseMarkdownLines(sourceText: string): Array<MarkdownLineNode> {
  let lines: Array<string> = sourceText.split('\n')
  let result: Array<MarkdownLineNode> = []
  let i: number = 0

  while (i < lines.length) {
    let line: string = lines[i]

    if (line.startsWith('# ')) {
      result.push(new MarkdownLineNode(line, line.substring(2), 30, '#1F2329', 700))
    } else if (line.startsWith('## ')) {
      result.push(new MarkdownLineNode(line, line.substring(3), 24, '#1F2329', 700))
    } else if (line.startsWith('### ')) {
      result.push(new MarkdownLineNode(line, line.substring(4), 20, '#1F2329', 500))
    } else if (line.startsWith('> ')) {
      result.push(new MarkdownLineNode(line, line.substring(2), 18, '#5C6370', 400))
    } else if (line.startsWith('- ') || line.startsWith('* ')) {
      result.push(new MarkdownLineNode(line, '• ' + line.substring(2), 18, '#1F2329', 400))
    } else if (/^[0-9]+\.\s/.test(line)) {
      result.push(new MarkdownLineNode(line, line, 18, '#1F2329', 400))
    } else {
      result.push(new MarkdownLineNode(line, line, 18, '#1F2329', 400))
    }

    i += 1
  }

  return result
}
