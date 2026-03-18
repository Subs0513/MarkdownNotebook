export class OpenNoteTab {
  id: number = 0
  title: string = ''
  content: string = ''

  constructor(id: number, title: string, content: string) {
    this.id = id
    this.title = title
    this.content = content
  }
}
