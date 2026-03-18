export function insertHeading(text: string, level: number): string {
  let safeLevel: number = level
  if (safeLevel < 1) {
    safeLevel = 1
  }
  if (safeLevel > 6) {
    safeLevel = 6
  }

  let prefix: string = ''
  let i: number = 0
  while (i < safeLevel) {
    prefix += '#'
    i += 1
  }
  return prefix + ' ' + text
}

export function insertQuote(text: string): string {
  return '> ' + text
}

export function insertBullet(text: string): string {
  return '- ' + text
}

export function insertOrderedList(text: string): string {
  return '1. ' + text
}

export function insertTaskUnchecked(text: string): string {
  return '- [ ] ' + text
}

export function insertTaskChecked(text: string): string {
  return '- [x] ' + text
}

export function insertCodeBlock(text: string): string {
  return '```\n' + text + '\n```'
}

export function insertBold(text: string): string {
  return '**' + text + '**'
}

export function insertItalic(text: string): string {
  return '*' + text + '*'
}

export function insertStrike(text: string): string {
  return '~~' + text + '~~'
}

export function insertInlineCode(text: string): string {
  return '`' + text + '`'
}

export function insertDivider(): string {
  return '---'
}

export function insertLink(text: string, url: string): string {
  return '[' + text + '](' + url + ')'
}
