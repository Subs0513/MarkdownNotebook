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

export function insertCodeBlock(text: string): string {
  return '```\n' + text + '\n```'
}
