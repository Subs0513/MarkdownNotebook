import { renderMarkdownToRichEditor } from '../utils/markdownRichRenderer'

@Component
export struct MarkdownRenderEditor {
  @Link sourceText: string
  @Link renderReady: boolean
  @Link needReloadRender: boolean
  controller: RichEditorController = new RichEditorController()
  onContentChanged: (() => void) | null = null

  build() {
    RichEditor({ controller: this.controller })
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(0)
      .onReady(() => {
        this.renderReady = true
        if (this.needReloadRender) {
          this.needReloadRender = false
        }
        renderMarkdownToRichEditor(this.controller, this.sourceText)
      })
      .onDidChange(() => {
        if (this.onContentChanged !== null) {
          this.onContentChanged()
        }
      })
  }
}
