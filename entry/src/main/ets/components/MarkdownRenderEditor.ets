import { parseMarkdownLines } from '../utils/markdownBlockParser'

@Component
export struct MarkdownRenderEditor {
  @Link sourceText: string
  @Link renderReady: boolean
  @Link needReloadRender: boolean
  controller: RichEditorController = new RichEditorController()
  onContentChanged: (() => void) | null = null

  private loadMarkdownToRichEditor(): void {
    let lines = parseMarkdownLines(this.sourceText)
    let i: number = 0
    while (i < lines.length) {
      let item = lines[i]
      this.controller.addTextSpan(item.text, {
        style: {
          fontSize: item.fontSize,
          fontColor: item.fontColor,
          fontWeight: item.fontWeight
        }
      })

      if (i !== lines.length - 1) {
        this.controller.addTextSpan('\n', {
          style: {
            fontSize: 18,
            fontColor: '#1F2329'
          }
        })
      }
      i += 1
    }
  }

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
        this.loadMarkdownToRichEditor()
      })
      .onDidChange(() => {
        if (this.onContentChanged !== null) {
          this.onContentChanged()
        }
      })
  }
}
