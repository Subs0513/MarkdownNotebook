import { MarkdownLineNode } from '../models/MarkdownNode'

function isDivider(line: string): boolean {
  let trimmed: string = line.trim()
  return trimmed === '---' || trimmed === '***' || trimmed === '___'
}

function isOrderedList(line: string): boolean {
  return /^[0-9]+\.\s/.test(line)
}

export function parseMarkdownLines(sourceText: string): Array<MarkdownLineNode> {
  let lines: Array<string> = sourceText.split('\n')
  let result: Array<MarkdownLineNode> = []
  let i: number = 0
  let inCodeBlock: boolean = false

  while (i < lines.length) {
    let line: string = lines[i]
    let trimmed: string = line.trim()

    if (trimmed.startsWith('```')) {
      if (!inCodeBlock) {
        let lang: string = trimmed.substring(3)
        let title: string = lang.length > 0 ? '代码块 · ' + lang : '代码块'
        result.push(new MarkdownLineNode(line, title, 15, '#6B7280', 500))
        inCodeBlock = true
      } else {
        result.push(new MarkdownLineNode(line, '', 15, '#6B7280', 400))
        inCodeBlock = false
      }
      i += 1
      continue
    }

    if (inCodeBlock) {
      result.push(new MarkdownLineNode(line, line, 16, '#C7254E', 400))
      i += 1
      continue
    }

    if (trimmed.length === 0) {
      result.push(new MarkdownLineNode(line, '', 18, '#1F2329', 400))
    } else if (line.startsWith('# ')) {
      result.push(new MarkdownLineNode(line, line.substring(2), 30, '#1F2329', 700))
    } else if (line.startsWith('## ')) {
      result.push(new MarkdownLineNode(line, line.substring(3), 26, '#1F2329', 700))
    } else if (line.startsWith('### ')) {
      result.push(new MarkdownLineNode(line, line.substring(4), 22, '#1F2329', 600))
    } else if (line.startsWith('#### ')) {
      result.push(new MarkdownLineNode(line, line.substring(5), 20, '#1F2329', 600))
    } else if (line.startsWith('##### ')) {
      result.push(new MarkdownLineNode(line, line.substring(6), 18, '#1F2329', 600))
    } else if (line.startsWith('###### ')) {
      result.push(new MarkdownLineNode(line, line.substring(7), 17, '#1F2329', 600))
    } else if (line.startsWith('> ')) {
      result.push(new MarkdownLineNode(line, line.substring(2), 18, '#5C6370', 400))
    } else if (line.startsWith('- [ ] ')) {
      result.push(new MarkdownLineNode(line, '☐ ' + line.substring(6), 18, '#1F2329', 400))
    } else if (line.startsWith('- [x] ') || line.startsWith('- [X] ')) {
      result.push(new MarkdownLineNode(line, '☑ ' + line.substring(6), 18, '#1F2329', 400))
    } else if (line.startsWith('- ') || line.startsWith('* ')) {
      result.push(new MarkdownLineNode(line, '• ' + line.substring(2), 18, '#1F2329', 400))
    } else if (isOrderedList(line)) {
      result.push(new MarkdownLineNode(line, line, 18, '#1F2329', 400))
    } else if (isDivider(line)) {
      result.push(new MarkdownLineNode(line, '────────────────', 18, '#D0D7DE', 400))
    } else {
      result.push(new MarkdownLineNode(line, line, 18, '#1F2329', 400))
    }

    i += 1
  }

  return result
}
