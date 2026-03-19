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
import { OpenNoteTab } from '../models/OpenNoteTab'
import { EditorTopBar } from '../components/EditorTopBar'
import { EditorToolbar } from '../components/EditorToolbar'
import { MarkdownSourceEditor } from '../components/MarkdownSourceEditor'
import { MarkdownRenderEditor } from '../components/MarkdownRenderEditor'
import { EditorBottomBar } from '../components/EditorBottomBar'
import {
  updateTabSnapshot,
  findTabById,
  createTabByCurrentLength,
  closeActiveTab
} from '../utils/editorTabHelper'

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

  private syncActiveTab(): void {
    updateTabSnapshot(this.openTabs, this.activeTabId, this.noteTitle, this.sourceText)
  }

  private openTab(tabId: number): void {
    this.syncActiveTab()
    let tab: OpenNoteTab | null = findTabById(this.openTabs, tabId)
    if (tab === null) {
      return
    }

    this.activeTabId = tab.id
    this.noteTitle = tab.title
    this.sourceText = tab.content
    if (!this.showSource) {
      this.resetRichEditor()
    }
  }

  private createNewTab(): void {
    this.syncActiveTab()
    let newTab: OpenNoteTab = createTabByCurrentLength(this.openTabs)
    this.openTabs.push(newTab)
    this.activeTabId = newTab.id
    this.noteTitle = newTab.title
    this.sourceText = newTab.content
    if (!this.showSource) {
      this.resetRichEditor()
    }
  }

  private closeCurrentTab(): void {
    let result = closeActiveTab(this.openTabs, this.activeTabId)
    if (result.nextTab === null) {
      return
    }

    this.openTabs = result.tabs
    this.activeTabId = result.nextTab.id
    this.noteTitle = result.nextTab.title
    this.sourceText = result.nextTab.content
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
    this.syncActiveTab()
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

  build() {
    Column() {
      EditorTopBar({
        openTabs: this.openTabs,
        activeTabId: this.activeTabId,
        onBack: () => {
          router.back()
        },
        onOpenTab: (tabId: number) => {
          this.openTab(tabId)
        },
        onCreateTab: () => {
          this.createNewTab()
        },
        onCloseCurrentTab: () => {
          this.closeCurrentTab()
        }
      })

      EditorToolbar({
        noteTitle: this.noteTitle,
        showSource: this.showSource,
        onToggleMode: () => {
          this.toggleMode()
        },
        onToolbarAction: (action: string) => {
          this.applyToolbarAction(action)
        }
      })

      Column() {
        if (this.showSource) {
          MarkdownSourceEditor({
            sourceText: $sourceText,
            onTextChanged: () => {
              this.syncActiveTab()
            }
          })
        } else {
          if (this.renderEditorVisible) {
            MarkdownRenderEditor({
              sourceText: $sourceText,
              renderReady: $renderReady,
              needReloadRender: $needReloadRender,
              controller: this.richController
            })
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16, top: 12, bottom: 0 })

      EditorBottomBar({
        wordCount: this.getWordCount(),
        saveStatusText: this.showSource ? '源代码编辑' : '渲染预览'
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF1F5')
  }
}
