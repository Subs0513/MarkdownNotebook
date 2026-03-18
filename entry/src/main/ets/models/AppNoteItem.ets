export class AppNoteItem {
  id: number = 0
  title: string = ''
  updateTime: string = ''
  favorite: boolean = false
  content: string = ''
  folderKey: string = ''

  constructor(id: number, title: string, updateTime: string, favorite: boolean, content: string, folderKey: string = '') {
    this.id = id
    this.title = title
    this.updateTime = updateTime
    this.favorite = favorite
    this.content = content
    this.folderKey = folderKey
  }
}
