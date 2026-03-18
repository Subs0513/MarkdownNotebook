import { router } from '@kit.ArkUI'

@Entry
@Component
struct EditorPage {
  @State noteTitle: string = '未命名笔记'
  @State sourceText: string =
    '# 未命名笔记\n' +
      '\n' +
      '现在默认是 RichEditor 连续编辑模式。\n' +
      '\n' +
      '## 这一版解决的问题\n' +
      '- 支持连续输入\n' +
      '- 支持回车换行\n' +
      '- 支持一次性粘贴多行\n' +
      '\n' +
      '> 点击左下角可以切换到源代码模式。'

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

  private insertStyledLine(line: string, isLast: boolean): void {
    if (line.startsWith('# ')) {
      this.richController.addTextSpan(line.substring(2), {
        style: {
          fontSize: 30,
          fontWeight: FontWeight.Bold,
          fontColor: '#1F2329'
        }
      })
    } else if (line.startsWith('## ')) {
      this.richController.addTextSpan(line.substring(3), {
        style: {
          fontSize: 24,
          fontWeight: FontWeight.Bold,
          fontColor: '#1F2329'
        }
      })
    } else if (line.startsWith('### ')) {
      this.richController.addTextSpan(line.substring(4), {
        style: {
          fontSize: 20,
          fontWeight: FontWeight.Medium,
          fontColor: '#1F2329'
        }
      })
    } else if (line.startsWith('> ')) {
      this.richController.addTextSpan(line.substring(2), {
        style: {
          fontSize: 18,
          fontColor: '#5C6370'
        }
      })
    } else if (line.startsWith('- ')) {
      this.richController.addTextSpan('• ' + line.substring(2), {
        style: {
          fontSize: 18,
          fontColor: '#1F2329'
        }
      })
    } else if (line.startsWith('* ')) {
      this.richController.addTextSpan('• ' + line.substring(2), {
        style: {
          fontSize: 18,
          fontColor: '#1F2329'
        }
      })
    } else {
      this.richController.addTextSpan(line, {
        style: {
          fontSize: 18,
          fontColor: '#1F2329'
        }
      })
    }

    if (!isLast) {
      this.richController.addTextSpan('\n', {
        style: {
          fontSize: 18,
          fontColor: '#1F2329'
        }
      })
    }
  }

  private loadMarkdownToRichEditor(): void {
    let lines: Array<string> = this.sourceText.split('\n')
    let i: number = 0
    while (i < lines.length) {
      this.insertStyledLine(lines[i], i === lines.length - 1)
      i += 1
    }
  }

  @Builder
  private buildRenderModeArea() {
    RichEditor({ controller: this.richController })
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .onReady(() => {
        this.renderReady = true
        if (this.needReloadRender) {
          this.needReloadRender = false
        }
        this.loadMarkdownToRichEditor()
      })
      .onDidChange(() => {
        this.syncSourceFromRichEditor()
      })
  }

  @Builder
  private buildSourceModeArea() {
    TextArea({
      text: this.sourceText,
      placeholder: '请输入 Markdown 源代码...'
    })
      .width('100%')
      .height('100%')
      .fontSize(18)
      .fontColor('#1F2329')
      .placeholderColor('#9AA0AA')
      .backgroundColor(Color.Transparent)
      .padding({ left: 20, right: 20, top: 20, bottom: 80 })
      .onChange((value: string) => {
        this.sourceText = value
      })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor('#1F2329')
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor('#F1F3F6')
        .justifyContent(FlexAlign.Center)
        .margin({ right: 16 })
        .onClick(() => {
          if (!this.showSource) {
            this.syncSourceFromRichEditor()
          }
          router.back()
        })

        Column() {
          Text(this.noteTitle)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2329')

          Text(this.showSource ? '源代码模式' : '渲染编辑模式')
            .fontSize(13)
            .fontColor('#6B7280')
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 14 })
      .backgroundColor('#F7F8FA')

      Stack({ alignContent: Alignment.BottomStart }) {
        Column() {
          if (this.showSource) {
            this.buildSourceModeArea()
          } else {
            this.buildRenderModeArea()
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(22)

        Row() {
          Button(this.showSource ? '显示渲染效果' : '显示源代码')
            .type(ButtonType.Capsule)
            .fontSize(14)
            .fontColor('#1F2329')
            .backgroundColor('#EEF1F6')
            .height(38)
            .onClick(() => {
              this.toggleMode()
            })

          Blank()

          Text(this.getWordCount().toString() + ' 字')
            .fontSize(14)
            .fontColor('#7A808A')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius({
          topLeft: 0,
          topRight: 0,
          bottomLeft: 22,
          bottomRight: 22
        })
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ left: 16, right: 16, top: 8, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF1F5')
  }
}