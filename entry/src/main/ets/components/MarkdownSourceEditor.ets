import { EDITOR_PLACEHOLDER_COLOR, EDITOR_TEXT_COLOR } from '../constants/editorConstants'

@Component
export struct MarkdownSourceEditor {
  @Link sourceText: string

  build() {
    TextArea({
      text: this.sourceText,
      placeholder: '请输入 Markdown 源代码...'
    })
      .width('100%')
      .height('100%')
      .fontSize(18)
      .fontColor(EDITOR_TEXT_COLOR)
      .placeholderColor(EDITOR_PLACEHOLDER_COLOR)
      .backgroundColor(Color.Transparent)
      .borderRadius(0)
      .padding({ left: 20, right: 20, top: 20, bottom: 80 })
      .onChange((value: string) => {
        this.sourceText = value
      })
  }
}
