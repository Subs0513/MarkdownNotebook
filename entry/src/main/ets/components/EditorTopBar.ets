import { router } from '@kit.ArkUI'
import { EDITOR_HEADER_COLOR, EDITOR_SUBTEXT_COLOR, EDITOR_TEXT_COLOR } from '../constants/editorConstants'

@Component
export struct EditorTopBar {
  @Prop noteTitle: string
  @Prop showSource: boolean
  onBack: (() => void) | null = null

  build() {
    Row() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor(EDITOR_TEXT_COLOR)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor('#F1F3F6')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })
      .onClick(() => {
        if (this.onBack !== null) {
          this.onBack()
        } else {
          router.back()
        }
      })

      Column() {
        Text(this.noteTitle)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(EDITOR_TEXT_COLOR)

        Text(this.showSource ? '源代码模式' : '渲染编辑模式')
          .fontSize(13)
          .fontColor(EDITOR_SUBTEXT_COLOR)
          .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .backgroundColor(EDITOR_HEADER_COLOR)
  }
}
