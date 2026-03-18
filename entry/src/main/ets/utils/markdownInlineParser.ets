export class MarkdownInlineSegment {
  type: string = 'text'
  text: string = ''
  href: string = ''

  constructor(type: string, text: string, href: string = '') {
    this.type = type
    this.text = text
    this.href = href
  }
}

function pushPlainIfNeeded(target: Array<MarkdownInlineSegment>, value: string): void {
  if (value.length > 0) {
    target.push(new MarkdownInlineSegment('text', value))
  }
}

export function parseInlineSegments(text: string): Array<MarkdownInlineSegment> {
  let result: Array<MarkdownInlineSegment> = []
  let i: number = 0
  let buffer: string = ''

  while (i < text.length) {
    if (i + 1 < text.length && text.substring(i, i + 2) === '![') {
      let closeBracket: number = text.indexOf(']', i + 2)
      let openParen: number = closeBracket >= 0 ? text.indexOf('(', closeBracket) : -1
      let closeParen: number = openParen >= 0 ? text.indexOf(')', openParen) : -1
      if (closeBracket >= 0 && openParen === closeBracket + 1 && closeParen >= 0) {
        pushPlainIfNeeded(result, buffer)
        buffer = ''
        let alt: string = text.substring(i + 2, closeBracket)
        let url: string = text.substring(openParen + 1, closeParen)
        let display: string = alt.length > 0 ? '[图片] ' + alt : '[图片]'
        result.push(new MarkdownInlineSegment('image', display, url))
        i = closeParen + 1
        continue
      }
    }

    if (text.charAt(i) === '[') {
      let closeBracket2: number = text.indexOf(']', i + 1)
      let openParen2: number = closeBracket2 >= 0 ? text.indexOf('(', closeBracket2) : -1
      let closeParen2: number = openParen2 >= 0 ? text.indexOf(')', openParen2) : -1
      if (closeBracket2 >= 0 && openParen2 === closeBracket2 + 1 && closeParen2 >= 0) {
        pushPlainIfNeeded(result, buffer)
        buffer = ''
        let linkText: string = text.substring(i + 1, closeBracket2)
        let linkUrl: string = text.substring(openParen2 + 1, closeParen2)
        result.push(new MarkdownInlineSegment('link', linkText, linkUrl))
        i = closeParen2 + 1
        continue
      }
    }

    if (text.charAt(i) === '`') {
      let closeCode: number = text.indexOf('`', i + 1)
      if (closeCode > i + 1) {
        pushPlainIfNeeded(result, buffer)
        buffer = ''
        result.push(new MarkdownInlineSegment('code', text.substring(i + 1, closeCode)))
        i = closeCode + 1
        continue
      }
    }

    if (i + 1 < text.length && text.substring(i, i + 2) === '**') {
      let closeBold: number = text.indexOf('**', i + 2)
      if (closeBold > i + 1) {
        pushPlainIfNeeded(result, buffer)
        buffer = ''
        result.push(new MarkdownInlineSegment('bold', text.substring(i + 2, closeBold)))
        i = closeBold + 2
        continue
      }
    }

    if (i + 1 < text.length && text.substring(i, i + 2) === '~~') {
      let closeStrike: number = text.indexOf('~~', i + 2)
      if (closeStrike > i + 1) {
        pushPlainIfNeeded(result, buffer)
        buffer = ''
        result.push(new MarkdownInlineSegment('strike', text.substring(i + 2, closeStrike)))
        i = closeStrike + 2
        continue
      }
    }

    if (text.charAt(i) === '*') {
      let closeItalic: number = text.indexOf('*', i + 1)
      if (closeItalic > i + 1) {
        pushPlainIfNeeded(result, buffer)
        buffer = ''
        result.push(new MarkdownInlineSegment('italic', text.substring(i + 1, closeItalic)))
        i = closeItalic + 1
        continue
      }
    }

    buffer += text.charAt(i)
    i += 1
  }

  pushPlainIfNeeded(result, buffer)
  return result
}
