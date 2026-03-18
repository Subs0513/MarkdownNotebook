import { router, window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import {
  insertBold,
  insertCodeBlock,
  insertDivider,
  insertHeading,
  insertInlineCode,
  insertItalic,
  insertBullet,
  insertOrderedList,
  insertQuote,
  insertTaskUnchecked,
  insertLink
} from '../utils/markdownCommands'

class OpenNoteTab {
  id: number = 0
  title: string = ''
  content: string = ''

  constructor(id: number, title: string, content: string) {
    this.id = id
    this.title = title
    this.content = content
  }
}

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
  @State openTabs: Array<OpenNoteTab> = []
  @State activeTabId: number = 1
  @State toolbarMenusVisible: boolean = false
  @State renderEditorVisible: boolean = true

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

    this.openTabs = [
      new OpenNoteTab(1, this.noteTitle, this.sourceText),
      new OpenNoteTab(2, '草稿本', '# 草稿本\n\n在这里快速记录想法。'),
      new OpenNoteTab(3, '阅读笔记', '# 阅读笔记\n\n- 论文一\n- 论文二')
    ]
    this.activeTabId = 1
    this.hideSystemBars()
  }

  aboutToDisappear(): void {
    this.showSystemBars()
  }

  private async hideSystemBars(): Promise<void> {
    try {
      let context: common.UIAbilityContext =
        this.getUIContext().getHostContext() as common.UIAbilityContext
      let lastWindow: window.Window = await window.getLastWindow(context)
      await lastWindow.setWindowLayoutFullScreen(true)
      await lastWindow.setSpecificSystemBarEnabled('status', false)
      await lastWindow.setSpecificSystemBarEnabled('navigationIndicator', false)
    } catch (err) {
      console.error('hideSystemBars failed')
    }
  }

  private async showSystemBars(): Promise<void> {
    try {
      let context: common.UIAbilityContext =
        this.getUIContext().getHostContext() as common.UIAbilityContext
      let lastWindow: window.Window = await window.getLastWindow(context)
      await lastWindow.setSpecificSystemBarEnabled('status', true)
      await lastWindow.setSpecificSystemBarEnabled('navigationIndicator', true)
    } catch (err) {
      console.error('showSystemBars failed')
    }
  }

  private getWordCount(): number {
    return this.sourceText.length
  }

  private resetRichEditor(): void {
    this.renderReady = false
    this.needReloadRender = true
    this.renderEditorVisible = false
    this.richController = new RichEditorController()
    setTimeout(() => {
      this.renderEditorVisible = true
    }, 0)
  }

  private switchToRenderMode(): void {
    this.showSource = false
    this.resetRichEditor()
  }

  private switchToSourceMode(): void {
    this.showSource = true
  }

  private toggleMode(): void {
    if (this.showSource) {
      this.switchToRenderMode()
    } else {
      this.switchToSourceMode()
    }
  }

  private updateActiveTabContent(): void {
    let i: number = 0
    while (i < this.openTabs.length) {
      if (this.openTabs[i].id === this.activeTabId) {
        this.openTabs[i].content = this.sourceText
        this.openTabs[i].title = this.noteTitle
        break
      }
      i += 1
    }
  }

  private openTab(tabId: number): void {
    this.updateActiveTabContent()
    let i: number = 0
    while (i < this.openTabs.length) {
      if (this.openTabs[i].id === tabId) {
        this.activeTabId = tabId
        this.noteTitle = this.openTabs[i].title
        this.sourceText = this.openTabs[i].content
        if (!this.showSource) {
          this.resetRichEditor()
        }
        return
      }
      i += 1
    }
  }

  private createNewTab(): void {
    this.updateActiveTabContent()
    let newId: number = this.openTabs.length + 1
    let title: string = '未命名笔记 ' + newId.toString()
    let content: string = '# ' + title + '\n\n在这里开始记录内容。'
    this.openTabs.push(new OpenNoteTab(newId, title, content))
    this.activeTabId = newId
    this.noteTitle = title
    this.sourceText = content
    if (!this.showSource) {
      this.resetRichEditor()
    }
  }

  private closeCurrentTab(): void {
    if (this.openTabs.length <= 1) {
      return
    }
    let removeIndex: number = -1
    let i: number = 0
    while (i < this.openTabs.length) {
      if (this.openTabs[i].id === this.activeTabId) {
        removeIndex = i
        break
      }
      i += 1
    }
    if (removeIndex < 0) {
      return
    }
    this.openTabs.splice(removeIndex, 1)
    let nextIndex: number = removeIndex
    if (nextIndex >= this.openTabs.length) {
      nextIndex = this.openTabs.length - 1
    }
    this.activeTabId = this.openTabs[nextIndex].id
    this.noteTitle = this.openTabs[nextIndex].title
    this.sourceText = this.openTabs[nextIndex].content
    if (!this.showSource) {
      this.resetRichEditor()
    }
  }

  private appendSnippet(snippet: string): void {
    let prefix: string = this.sourceText
    if (prefix.length > 0 && !prefix.endsWith('\n')) {
      prefix += '\n'
    }
    this.sourceText = prefix + snippet
    this.updateActiveTabContent()
    if (!this.showSource) {
      this.resetRichEditor()
    }
  }

  private applyToolbarAction(action: string): void {
    if (action === 'title') {
      this.appendSnippet(insertHeading('标题', 1))
    } else if (action === 'h2') {
      this.appendSnippet(insertHeading('二级标题', 2))
    } else if (action === 'bold') {
      this.appendSnippet(insertBold('粗体文本'))
    } else if (action === 'italic') {
      this.appendSnippet(insertItalic('斜体文本'))
    } else if (action === 'code') {
      this.appendSnippet(insertCodeBlock('code here'))
    } else if (action === 'inlineCode') {
      this.appendSnippet(insertInlineCode('inline code'))
    } else if (action === 'quote') {
      this.appendSnippet(insertQuote('引用文本'))
    } else if (action === 'bullet') {
      this.appendSnippet(insertBullet('列表项'))
    } else if (action === 'ordered') {
      this.appendSnippet(insertOrderedList('列表项'))
    } else if (action === 'task') {
      this.appendSnippet(insertTaskUnchecked('待办事项'))
    } else if (action === 'divider') {
      this.appendSnippet(insertDivider())
    } else if (action === 'link') {
      this.appendSnippet(insertLink('链接文字', 'https://example.com'))
    } else if (action === 'mode') {
      this.toggleMode()
    }
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
      this.richController.addTextSpan('▍ ' + line.substring(2), {
        style: {
          fontSize: 18,
          fontColor: '#5C6370'
        }
      })
    } else if (line.startsWith('- [ ] ')) {
      this.richController.addTextSpan('☐ ' + line.substring(6), {
        style: {
          fontSize: 18,
          fontColor: '#1F2329'
        }
      })
    } else if (line.startsWith('- ')) {
      this.richController.addTextSpan('• ' + line.substring(2), {
        style: {
          fontSize: 18,
          fontColor: '#1F2329'
        }
      })
    } else if (line.startsWith('1. ')) {
      this.richController.addTextSpan(line, {
        style: {
          fontSize: 18,
          fontColor: '#1F2329'
        }
      })
    } else if (line === '---') {
      this.richController.addTextSpan('────────────', {
        style: {
          fontSize: 18,
          fontColor: '#9AA0AA'
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
  private buildNavBar() {
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
        router.back()
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
                  if (tab.id === this.activeTabId) {
                    this.closeCurrentTab()
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
              this.openTab(tab.id)
            })
          })
        }
      }
      .width('64%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .margin({ right: 12 })

      Blank()

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
          this.createNewTab()
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
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 16, right: 16, top: 10, bottom: 8 })
    .backgroundColor('#F7F8FA')
  }

  @Builder
  private buildFormatToolbar() {
    Column() {
      Row() {
        Text(this.noteTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#374151')
        Blank()
        Button(this.showSource ? '渲染' : '源码')
          .type(ButtonType.Capsule)
          .fontSize(13)
          .fontColor('#374151')
          .backgroundColor('#EEF1F6')
          .height(32)
          .onClick(() => {
            this.toggleMode()
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

  @Builder
  private buildToolbarButton(label: string, action: string) {
    Button(label)
      .type(ButtonType.Capsule)
      .fontSize(13)
      .fontColor('#1F2329')
      .backgroundColor('#EEF1F6')
      .height(34)
      .onClick(() => {
        this.applyToolbarAction(action)
      })
  }

  @Builder
  private buildRenderModeArea() {
    RichEditor({ controller: this.richController })
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
      .borderRadius(0)
      .padding({ left: 20, right: 20, top: 20, bottom: 24 })
      .onChange((value: string) => {
        this.sourceText = value
        this.updateActiveTabContent()
      })
  }

  build() {
    Column() {
      this.buildNavBar()
      this.buildFormatToolbar()

      Column() {
        if (this.showSource) {
          this.buildSourceModeArea()
        } else {
          if (this.renderEditorVisible) {
            this.buildRenderModeArea()
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16, top: 12, bottom: 0 })

      Row() {
        Text(this.showSource ? '源代码编辑' : '渲染预览')
          .fontSize(14)
          .fontColor('#6B7280')
        Blank()
        Text(this.getWordCount().toString() + ' 字')
          .fontSize(14)
          .fontColor('#7A808A')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 12 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF1F5')
  }
}
