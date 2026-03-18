import { router } from '@kit.ArkUI'
import { EditorTopBar } from '../components/EditorTopBar'
import { EditorBottomBar } from '../components/EditorBottomBar'
import { MarkdownSourceEditor } from '../components/MarkdownSourceEditor'
import { MarkdownRenderEditor } from '../components/MarkdownRenderEditor'
import { DEFAULT_MARKDOWN_TEXT, EDITOR_BG_COLOR, EDITOR_PANEL_COLOR } from '../constants/editorConstants'
import { hideSystemBars, showSystemBars } from '../utils/windowHelper'

@Entry
@Component
struct EditorPage {
  @State noteTitle: string = '未命名笔记'
  @State sourceText: string = DEFAULT_MARKDOWN_TEXT
  @State showSource: boolean = false
  @State renderReady: boolean = false
  @State needReloadRender: boolean = false

  private richController: RichEditorController = new RichEditorController()

  aboutToAppear(): void {
    let params: Object | undefined = router.getParams()
    if (params) {
      let recordParams: Record<string, Object> = params as Record<string, Object>
      let titleValue: Object = recordParams['noteTitle']
      let contentValue: Object = recordParams['noteContent']

      if (typeof titleValue === 'string') {
        this.noteTitle = titleValue as string
      }

      if (typeof contentValue === 'string') {
        let incoming: string = contentValue as string
        if (incoming.length > 0) {
          this.sourceText = incoming
        }
      }
    }

    hideSystemBars(this.getUIContext())
  }

  aboutToDisappear(): void {
    showSystemBars(this.getUIContext())
  }

  private getWordCount(): number {
    return this.sourceText.length
  }

  private resetRichEditor(): void {
    this.richController = new RichEditorController()
    this.renderReady = false
    this.needReloadRender = true
  }

  private switchToRenderMode(): void {
    this.showSource = false
    this.resetRichEditor()
  }

  private switchToSourceMode(): void {
    this.syncSourceFromRichEditor()
    this.showSource = true
  }

  private toggleMode(): void {
    if (this.showSource) {
      this.switchToRenderMode()
    } else {
      this.switchToSourceMode()
    }
  }

  private syncSourceFromRichEditor(): void {
    if (!this.renderReady) {
      return
    }

    let spans: Array<RichEditorImageSpanResult | RichEditorTextSpanResult> =
      this.richController.getSpans({ start: -1, end: -1 })

    let result: string = ''
    let i: number = 0

    while (i < spans.length) {
      let item: RichEditorImageSpanResult | RichEditorTextSpanResult = spans[i]

      if (typeof (item as RichEditorTextSpanResult)['value'] !== 'undefined') {
        let textSpan: RichEditorTextSpanResult = item as RichEditorTextSpanResult
        result += textSpan.value
      }

      i += 1
    }

    this.sourceText = result
  }

  private handleBack(): void {
    if (!this.showSource) {
      this.syncSourceFromRichEditor()
    }
    router.back()
  }

  build() {
    Column() {
      EditorTopBar({
        noteTitle: this.noteTitle,
        showSource: this.showSource,
        onBack: () => {
          this.handleBack()
        }
      })

      Stack({ alignContent: Alignment.BottomStart }) {
        Column() {
          if (this.showSource) {
            MarkdownSourceEditor({ sourceText: $sourceText })
          } else {
            MarkdownRenderEditor({
              sourceText: $sourceText,
              renderReady: $renderReady,
              needReloadRender: $needReloadRender,
              controller: this.richController,
              onContentChanged: () => {
                this.syncSourceFromRichEditor()
              }
            })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(EDITOR_PANEL_COLOR)
        .borderRadius(0)

        EditorBottomBar({
          showSource: this.showSource,
          wordCount: this.getWordCount(),
          onToggleMode: () => {
            this.toggleMode()
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ left: 16, right: 16, top: 8, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(EDITOR_BG_COLOR)
  }
}
