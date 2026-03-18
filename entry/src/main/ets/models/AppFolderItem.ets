export class AppFolderItem {
  key: string = ''
  title: string = ''
  count: number = 0

  constructor(key: string, title: string, count: number) {
    this.key = key
    this.title = title
    this.count = count
  }
}
