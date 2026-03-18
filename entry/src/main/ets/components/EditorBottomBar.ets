@Component
export struct EditorBottomBar {
  @Prop wordCount: number
  @Prop saveStatusText: string

  build() {
    Row() {
      Text(this.saveStatusText)
        .fontSize(13)
        .fontColor('#6B7280')

      Blank()

      Text(this.wordCount.toString() + ' 字')
        .fontSize(13)
        .fontColor('#7A808A')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
