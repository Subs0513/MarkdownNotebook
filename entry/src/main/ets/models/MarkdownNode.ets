export class MarkdownLineNode {
  raw: string = ''
  text: string = ''
  fontSize: number = 18
  fontColor: string = '#1F2329'
  fontWeight: number = 400

  constructor(raw: string, text: string, fontSize: number, fontColor: string, fontWeight: number) {
    this.raw = raw
    this.text = text
    this.fontSize = fontSize
    this.fontColor = fontColor
    this.fontWeight = fontWeight
  }
}
