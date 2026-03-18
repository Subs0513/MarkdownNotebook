import { router } from '@kit.ArkUI'
import { OpenNoteTab } from '../models/OpenNoteTab'

@Component
export struct EditorTopBar {
  @Prop noteTitle: string
  @Prop openTabs: Array<OpenNoteTab>
  @Prop activeTabId: number
  @Prop showSource: boolean

  onBack: (() => void) | null = null
  onOpenTab: ((tabId: number) => void) | null = null
  onCreateTab: (() => void) | null = null
  onCloseCurrentTab: (() => void) | null = null
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

  @Builder
  private buildNavRow() {
    Row() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#1F2329')
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .backgroundColor('#F1F3F6')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 14 })
      .onClick(() => {
        if (this.onBack !== null) {
          this.onBack()
        } else {
          router.back()
        }
      })

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.openTabs, (tab: OpenNoteTab) => {
            Row() {
              Text(tab.title)
                .fontSize(16)
                .fontColor(tab.id === this.activeTabId ? '#111827' : '#4B5563')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text('×')
                .fontSize(18)
                .fontColor('#6B7280')
                .margin({ left: 10 })
                .onClick(() => {
                  if (tab.id === this.activeTabId && this.onCloseCurrentTab !== null) {
                    this.onCloseCurrentTab()
                  }
                })
            }
            .width(220)
            .height(52)
            .padding({ left: 18, right: 18 })
            .borderRadius(18)
            .backgroundColor(tab.id === this.activeTabId ? '#FFFFFF' : '#EEF1F5')
            .border({ width: 1, color: tab.id === this.activeTabId ? '#D8DEE8' : '#EEF1F5' })
            .onClick(() => {
              if (this.onOpenTab !== null) {
                this.onOpenTab(tab.id)
              }
            })
          })
        }
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      Row({ space: 10 }) {
        Row() {
          Text('+')
            .fontSize(24)
            .fontColor('#1F2329')
        }
        .width(44)
        .height(44)
        .borderRadius(22)
        .backgroundColor('#F1F3F6')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (this.onCreateTab !== null) {
            this.onCreateTab()
          }
        })

        Row() {
          Text('⋯')
            .fontSize(24)
            .fontColor('#1F2329')
        }
        .width(44)
        .height(44)
        .borderRadius(22)
        .backgroundColor('#F1F3F6')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 8 })
    .backgroundColor('#F7F8FA')
  }

  @Builder
  private buildToolbarRow() {
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
          this.buildToolbarButton('删除线', 'strike')
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

  build() {
    Column() {
      this.buildNavRow()
      this.buildToolbarRow()
    }
    .width('100%')
  }
}
