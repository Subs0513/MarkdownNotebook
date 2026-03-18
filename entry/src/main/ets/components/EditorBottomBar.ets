import { EDITOR_BUTTON_COLOR, EDITOR_MUTED_TEXT_COLOR, EDITOR_TEXT_COLOR } from '../constants/editorConstants'

@Component
export struct EditorBottomBar {
  @Prop showSource: boolean
  @Prop wordCount: number
  onToggleMode: (() => void) | null = null

  build() {
    Row() {
      Button(this.showSource ? '显示渲染效果' : '显示源代码')
        .type(ButtonType.Capsule)
        .fontSize(14)
        .fontColor(EDITOR_TEXT_COLOR)
        .backgroundColor(EDITOR_BUTTON_COLOR)
        .height(38)
        .onClick(() => {
          if (this.onToggleMode !== null) {
            this.onToggleMode()
          }
        })

      Blank()

      Text(this.wordCount.toString() + ' 字')
        .fontSize(14)
        .fontColor(EDITOR_MUTED_TEXT_COLOR)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(0)
  }
}
