export class AppMenuItem {
  key: string = ''
  title: string = ''
  count: number = 0
  iconText: string = ''

  constructor(key: string, title: string, count: number, iconText: string) {
    this.key = key
    this.title = title
    this.count = count
    this.iconText = iconText
  }
}
