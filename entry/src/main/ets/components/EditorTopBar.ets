import { router } from '@kit.ArkUI'
import { OpenNoteTab } from '../models/OpenNoteTab'

@Component
export struct EditorTopBar {
  @Prop openTabs: Array<OpenNoteTab>
  @Prop activeTabId: number

  onBack: (() => void) | null = null
  onOpenTab: ((tabId: number) => void) | null = null
  onCreateTab: (() => void) | null = null
  onCloseCurrentTab: (() => void) | null = null

  build() {
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
      .margin({ right: 12 })

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
          Text('☰')
            .fontSize(22)
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
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 16, right: 16, top: 10, bottom: 8 })
    .backgroundColor('#F7F8FA')
  }
}
