@Component
export struct EditorToolbar {
  @Prop noteTitle: string
  @Prop showSource: boolean

  onToggleMode: (() => void) | null = null
  onToolbarAction: ((action: string) => void) | null = null

  private emitToolbarAction(action: string): void {
    if (this.onToolbarAction !== null) {
      this.onToolbarAction(action)
    }
  }

  @Builder
  private buildToolbarButton(label: string, action: string) {
    Button(label)
      .type(ButtonType.Capsule)
      .fontSize(13)
      .fontColor('#1F2329')
      .backgroundColor('#EEF1F6')
      .height(34)
      .onClick(() => {
        this.emitToolbarAction(action)
      })
  }

  build() {
    Column() {
      Row() {
        Text(this.noteTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#374151')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        Button(this.showSource ? '渲染' : '源码')
          .type(ButtonType.Capsule)
          .fontSize(13)
          .fontColor('#374151')
          .backgroundColor('#EEF1F6')
          .height(32)
          .onClick(() => {
            if (this.onToggleMode !== null) {
              this.onToggleMode()
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 6, bottom: 8 })

      Scroll() {
        Row({ space: 10 }) {
          this.buildToolbarButton('标题', 'title')
          this.buildToolbarButton('二级标题', 'h2')
          this.buildToolbarButton('加粗', 'bold')
          this.buildToolbarButton('斜体', 'italic')
          this.buildToolbarButton('代码块', 'code')
          this.buildToolbarButton('行内代码', 'inlineCode')
          this.buildToolbarButton('引用', 'quote')
          this.buildToolbarButton('无序列表', 'bullet')
          this.buildToolbarButton('有序列表', 'ordered')
          this.buildToolbarButton('待办', 'task')
          this.buildToolbarButton('分割线', 'divider')
          this.buildToolbarButton('链接', 'link')
        }
        .padding({ left: 16, right: 16, top: 4, bottom: 10 })
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}
