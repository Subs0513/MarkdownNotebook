import { OpenNoteTab } from '../models/OpenNoteTab'

export function updateTabSnapshot(
  tabs: Array<OpenNoteTab>,
  activeTabId: number,
  noteTitle: string,
  sourceText: string
): void {
  let i: number = 0
  while (i < tabs.length) {
    if (tabs[i].id === activeTabId) {
      tabs[i].title = noteTitle
      tabs[i].content = sourceText
      return
    }
    i += 1
  }
}

export function findTabById(
  tabs: Array<OpenNoteTab>,
  tabId: number
): OpenNoteTab | null {
  let i: number = 0
  while (i < tabs.length) {
    if (tabs[i].id === tabId) {
      return tabs[i]
    }
    i += 1
  }
  return null
}

export function createTabByCurrentLength(
  tabs: Array<OpenNoteTab>
): OpenNoteTab {
  let newId: number = tabs.length + 1
  let title: string = '未命名笔记 ' + newId.toString()
  let content: string = '# ' + title + '\n\n在这里开始记录内容。'
  return new OpenNoteTab(newId, title, content)
}

export class CloseTabResult {
  tabs: Array<OpenNoteTab>
  nextTab: OpenNoteTab | null

  constructor(tabs: Array<OpenNoteTab>, nextTab: OpenNoteTab | null) {
    this.tabs = tabs
    this.nextTab = nextTab
  }
}

export function closeActiveTab(
  tabs: Array<OpenNoteTab>,
  activeTabId: number
): CloseTabResult {
  if (tabs.length <= 1) {
    return new CloseTabResult(tabs, null)
  }

  let removeIndex: number = -1
  let i: number = 0
  while (i < tabs.length) {
    if (tabs[i].id === activeTabId) {
      removeIndex = i
      break
    }
    i += 1
  }

  if (removeIndex < 0) {
    return new CloseTabResult(tabs, null)
  }

  tabs.splice(removeIndex, 1)
  let nextIndex: number = removeIndex
  if (nextIndex >= tabs.length) {
    nextIndex = tabs.length - 1
  }

  return new CloseTabResult(tabs, tabs[nextIndex])
}
