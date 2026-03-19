import { router } from '@kit.ArkUI'
import { AppMenuItem } from '../models/AppMenuItem'
import { AppFolderItem } from '../models/AppFolderItem'
import { AppNoteItem } from '../models/AppNoteItem'
import { DEFAULT_MARKDOWN_TEXT } from '../constants/editorConstants'

@Entry
@Component
struct Index {
  @State selectedMenuKey: string = 'recent'
  @State selectedFolderKey: string = ''
  @State folders: Array<AppFolderItem> = []
  @State noteItems: Array<AppNoteItem> = []
  @State showFolderMenu: boolean = false
  @State activeFolderKey: string = ''
  @State activeFolderTitle: string = ''
  @State folderMenuOffsetX: number = 0
  @State folderMenuOffsetY: number = 0
  @State showSettingsDialog: boolean = false

  private menuItems: Array<AppMenuItem> = [
    new AppMenuItem('all', '全部笔记', 0, '📄'),
    new AppMenuItem('recent', '最近笔记', 0, '🕘'),
    new AppMenuItem('favorite', '我的收藏', 0, '☆'),
    new AppMenuItem('deleted', '最近删除', 0, '🗑')
  ]

  aboutToAppear(): void {
    if (this.folders.length === 0) {
      this.folders = [
        new AppFolderItem('study', '学习笔记', 1),
        new AppFolderItem('product', '产品想法', 1),
        new AppFolderItem('draft', '草稿箱', 0)
      ]
    }

    if (this.noteItems.length === 0) {
      this.noteItems = [
        new AppNoteItem(1, 'Markdown 编辑器重构说明', '今天 21:36', true, DEFAULT_MARKDOWN_TEXT, 'study'),
        new AppNoteItem(2, 'HarmonyOS 开发随记', '昨天 18:20', false,
          '# HarmonyOS 开发随记\n\n## 当前目标\n- 完善 Markdown 语法\n- 继续优化编辑体验\n\n> 先把结构整理清楚。', 'product')
      ]
    }
  }

  private isMenuSelected(itemKey: string): boolean {
    return this.selectedMenuKey === itemKey && this.selectedFolderKey.length === 0
  }

  private isFolderSelected(folderKey: string): boolean {
    return this.selectedFolderKey === folderKey
  }

  private getCurrentTitle(): string {
    if (this.selectedFolderKey.length > 0) {
      let i: number = 0
      while (i < this.folders.length) {
        if (this.folders[i].key === this.selectedFolderKey) {
          return this.folders[i].title
        }
        i += 1
      }
    }

    let j: number = 0
    while (j < this.menuItems.length) {
      if (this.menuItems[j].key === this.selectedMenuKey) {
        return this.menuItems[j].title
      }
      j += 1
    }

    return '全部笔记'
  }

  private getFolderNoteCount(folderKey: string): number {
    let count: number = 0
    let i: number = 0
    while (i < this.noteItems.length) {
      if (this.noteItems[i].folderKey === folderKey) {
        count += 1
      }
      i += 1
    }
    return count
  }

  private getMenuCountByKey(key: string): number {
    if (key === 'all' || key === 'recent') {
      return this.noteItems.length
    }

    if (key === 'favorite') {
      let count: number = 0
      let i: number = 0
      while (i < this.noteItems.length) {
        if (this.noteItems[i].favorite) {
          count += 1
        }
        i += 1
      }
      return count
    }

    return 0
  }

  private getVisibleNotes(): Array<AppNoteItem> {
    let result: Array<AppNoteItem> = []
    let i: number = 0

    while (i < this.noteItems.length) {
      let note: AppNoteItem = this.noteItems[i]
      let folderMatched: boolean = this.selectedFolderKey.length === 0 || note.folderKey === this.selectedFolderKey
      let menuMatched: boolean = true

      if (this.selectedFolderKey.length === 0) {
        if (this.selectedMenuKey === 'favorite') {
          menuMatched = note.favorite
        } else if (this.selectedMenuKey === 'deleted') {
          menuMatched = false
        }
      }

      if (folderMatched && menuMatched) {
        result.push(note)
      }
      i += 1
    }

    return result
  }

  private toggleFavorite(noteId: number): void {
    let i: number = 0
    while (i < this.noteItems.length) {
      if (this.noteItems[i].id === noteId) {
        this.noteItems[i].favorite = !this.noteItems[i].favorite
        break
      }
      i += 1
    }
    this.noteItems = this.noteItems.slice()
  }

  private openEditor(noteTitle: string, noteContent: string): void {
    router.pushUrl({
      url: 'pages/EditorPage',
      params: {
        noteTitle: noteTitle,
        noteContent: noteContent
      }
    })
  }

  private openFolder(folder: AppFolderItem): void {
    this.selectedFolderKey = folder.key
    this.selectedMenuKey = ''
  }

  private openFolderActionMenu(folder: AppFolderItem): void {
    this.activeFolderKey = folder.key
    this.activeFolderTitle = folder.title

    let index: number = 0
    let i: number = 0
    while (i < this.folders.length) {
      if (this.folders[i].key === folder.key) {
        index = i
        break
      }
      i += 1
    }

    this.folderMenuOffsetX = 198
    this.folderMenuOffsetY = 292 + index * 54
    this.showFolderMenu = true
  }

  private closeFolderActionMenu(): void {
    this.showFolderMenu = false
  }

  private openSettingsDialog(): void {
    this.showSettingsDialog = true
  }

  private closeSettingsDialog(): void {
    this.showSettingsDialog = false
  }

  private getFolderTitleByKey(folderKey: string): string {
    let i: number = 0
    while (i < this.folders.length) {
      if (this.folders[i].key === folderKey) {
        return this.folders[i].title
      }
      i += 1
    }
    return '未命名文件夹'
  }

  private createSubFolder(): void {
    let newKey: string = this.activeFolderKey + '_child_' + this.folders.length.toString()
    let newTitle: string = this.activeFolderTitle + ' 子文件夹'
    this.folders.push(new AppFolderItem(newKey, newTitle, 0))
    this.folders = this.folders.slice()
    this.closeFolderActionMenu()
  }

  private renameFolder(): void {
    let i: number = 0
    while (i < this.folders.length) {
      if (this.folders[i].key === this.activeFolderKey) {
        this.folders[i].title = this.folders[i].title + '（重命名）'
        break
      }
      i += 1
    }
    this.folders = this.folders.slice()
    this.closeFolderActionMenu()
  }

  private moveFolder(): void {
    let i: number = 0
    while (i < this.folders.length) {
      if (this.folders[i].key === this.activeFolderKey) {
        if (i < this.folders.length - 1) {
          let current: AppFolderItem = this.folders[i]
          this.folders[i] = this.folders[i + 1]
          this.folders[i + 1] = current
        }
        break
      }
      i += 1
    }
    this.folders = this.folders.slice()
    this.closeFolderActionMenu()
  }

  private deleteFolder(): void {
    let result: Array<AppFolderItem> = []
    let i: number = 0
    while (i < this.folders.length) {
      if (this.folders[i].key !== this.activeFolderKey) {
        result.push(this.folders[i])
      }
      i += 1
    }
    this.folders = result

    if (this.selectedFolderKey === this.activeFolderKey) {
      this.selectedFolderKey = ''
      this.selectedMenuKey = 'all'
    }

    this.closeFolderActionMenu()
  }

  @Builder
  private buildSidebarTopButton() {
    Row() {
      Text('☰')
        .fontSize(24)
        .fontColor('#1F2329')
    }
    .width(54)
    .height(54)
    .borderRadius(27)
    .backgroundColor('#F1F3F6')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private buildSidebarMenuItem(item: AppMenuItem) {
    Row() {
      Text(item.iconText)
        .fontSize(20)
        .margin({ right: 12 })

      Text(item.title)
        .fontSize(18)
        .fontWeight(this.isMenuSelected(item.key) ? FontWeight.Medium : FontWeight.Regular)
        .fontColor('#1F2329')

      Blank()

      Text(this.getMenuCountByKey(item.key).toString())
        .fontSize(16)
        .fontColor(this.isMenuSelected(item.key) ? '#5B6472' : '#7C8493')
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.isMenuSelected(item.key) ? '#DDE6FF' : Color.Transparent)
    .borderRadius(16)
    .onClick(() => {
      this.selectedMenuKey = item.key
      this.selectedFolderKey = ''
    })
  }

  @Builder
  private buildFolderItem(folder: AppFolderItem) {
    Row() {
      Text('📁')
        .fontSize(20)
        .margin({ right: 10 })

      Text(folder.title)
        .fontSize(17)
        .fontWeight(this.isFolderSelected(folder.key) ? FontWeight.Medium : FontWeight.Regular)
        .fontColor('#1F2329')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank()

      Text(this.getFolderNoteCount(folder.key).toString())
        .fontSize(15)
        .fontColor('#7C8493')
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.isFolderSelected(folder.key) ? '#E7EEFF' : Color.Transparent)
    .borderRadius(14)
    .onClick(() => {
      this.openFolder(folder)
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.openFolderActionMenu(folder)
        })
    )
  }

  @Builder
  private buildHeaderActionButton(iconText: string, label: string, onTap: () => void) {
    Row() {
      Text(iconText)
        .fontSize(22)
        .fontColor('#2D3138')
        .margin({ right: label.length > 0 ? 6 : 0 })

      if (label.length > 0) {
        Text(label)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2D3138')
      }
    }
    .height(52)
    .padding({ left: 18, right: 18 })
    .borderRadius(26)
    .backgroundColor('#F1F3F6')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      onTap()
    })
  }

  @Builder
  private buildRightHeader() {
    Row() {
      Text(this.getCurrentTitle())
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2329')

      Blank()

      Row() {
        Text('搜索')
          .fontSize(18)
          .fontColor('#9AA1AD')
          .margin({ left: 16 })

        Blank()
      }
      .width(420)
      .height(52)
      .backgroundColor('#F1F3F6')
      .borderRadius(26)
      .margin({ right: 16 })

      this.buildHeaderActionButton('☰', '', () => {
        this.openSettingsDialog()
      })
    }
    .width('100%')
    .padding({ left: 28, right: 28, top: 20, bottom: 12 })
  }

  @Builder
  private buildNewNoteCard() {
    Row() {
      Row() {
        Text('+')
          .fontSize(24)
          .fontColor('#9AA1AD')
      }
      .width(52)
      .height(52)
      .borderRadius(12)
      .backgroundColor('#F7F8FA')
      .justifyContent(FlexAlign.Center)

      Text('新建笔记')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2329')
        .margin({ left: 18 })

      Blank()
    }
    .width('100%')
    .height(96)
    .padding({ left: 18, right: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .onClick(() => {
      this.openEditor('未命名笔记', DEFAULT_MARKDOWN_TEXT)
    })
  }

  @Builder
  private buildEmptyState() {
    Column() {
      Text('还没有笔记')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2329')

      Text(this.selectedFolderKey.length > 0 ? '这个文件夹里还没有内容' : '点击上方“新建笔记”，开始创建你的第一篇 Markdown 笔记')
        .fontSize(16)
        .fontColor('#7A8190')
        .margin({ top: 10 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 32 })
  }

  @Builder
  private buildNoteCard(item: AppNoteItem) {
    Row() {
      Row() {
        Text('MD')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(52)
      .height(52)
      .borderRadius(12)
      .backgroundColor('#F39AA9')
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(item.title)
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2329')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.updateTime)
          .fontSize(16)
          .fontColor('#7A8190')
          .margin({ top: 10 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .margin({ left: 18, right: 18 })

      Text(item.favorite ? '★' : '☆')
        .fontSize(28)
        .fontColor(item.favorite ? '#F2B500' : '#3B3F45')
        .margin({ right: 18 })
        .onClick(() => {
          this.toggleFavorite(item.id)
        })

      Text('⋮')
        .fontSize(30)
        .fontColor('#3B3F45')
    }
    .width('100%')
    .height(96)
    .padding({ left: 18, right: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .onClick(() => {
      this.openEditor(item.title, item.content)
    })
  }

  @Builder
  private buildLeftFolderList() {
    Column({ space: 6 }) {
      if (this.folders.length === 0) {
        Row() {
          Text('暂无文件夹')
            .fontSize(15)
            .fontColor('#98A1AE')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 4 })
      } else {
        ForEach(this.folders, (folder: AppFolderItem) => {
          this.buildFolderItem(folder)
        }, (folder: AppFolderItem) => folder.key)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  private buildRightContentArea() {
    Column({ space: 18 }) {
      this.buildNewNoteCard()

      if (this.getVisibleNotes().length === 0) {
        this.buildEmptyState()
      } else {
        ForEach(this.getVisibleNotes(), (item: AppNoteItem) => {
          this.buildNoteCard(item)
        }, (item: AppNoteItem) => item.id.toString())
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 28, right: 28, top: 8, bottom: 20 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  private buildFolderMenuItem(iconText: string, title: string, onTap: () => void) {
    Row() {
      Text(iconText)
        .fontSize(22)
        .margin({ right: 16 })

      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2329')

      Blank()
    }
    .width('100%')
    .height(54)
    .padding({ left: 20, right: 20 })
    .onClick(() => {
      onTap()
    })
  }

  @Builder
  private buildSettingsItem(title: string) {
    Row() {
      Text(title)
        .fontSize(18)
        .fontColor('#1F2329')

      Blank()

      Text('›')
        .fontSize(22)
        .fontColor('#A0A8B4')
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .borderRadius(16)
    .backgroundColor('#F7F9FC')
  }

  @Builder
  private buildSettingsSection(title: string, items: Array<string>) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8A93A2')
        .width('100%')

      ForEach(items, (item: string) => {
        this.buildSettingsItem(item)
      }, (item: string) => item)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildFolderActionDialog() {
    if (this.showFolderMenu) {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
        }
        .width('100%')
        .height('100%')
        .onClick(() => {
          this.closeFolderActionMenu()
        })

        Column() {
          this.buildFolderMenuItem('📂', '新建子文件夹', () => {
            this.createSubFolder()
          })

          Divider().color('#EEF1F5')

          this.buildFolderMenuItem('✏️', '重命名', () => {
            this.renameFolder()
          })

          Divider().color('#EEF1F5')

          this.buildFolderMenuItem('↕️', '移动', () => {
            this.moveFolder()
          })

          Divider().color('#EEF1F5')

          this.buildFolderMenuItem('🗑', '删除', () => {
            this.deleteFolder()
          })
        }
        .width(232)
        .backgroundColor('#FFFFFF')
        .borderRadius(22)
        .shadow({ radius: 24, color: '#26000000', offsetX: 0, offsetY: 8 })
        .position({ x: this.folderMenuOffsetX, y: this.folderMenuOffsetY })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  private buildSettingsDialog() {
    if (this.showSettingsDialog) {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
        .onClick(() => {
          this.closeSettingsDialog()
        })

        Column({ space: 20 }) {
          Row() {
            Text('设置')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2329')

            Blank()

            Text('✕')
              .fontSize(24)
              .fontColor('#6E7786')
              .onClick(() => {
                this.closeSettingsDialog()
              })
          }
          .width('100%')

          this.buildSettingsSection('常用设置', ['Markdown 语法设置', '问题与建议', '检查更新'])
          this.buildSettingsSection('隐私与信息', ['隐私声明', '收集个人信息清单'])
          this.buildSettingsSection('更多', ['关于', '服务协议'])
        }
        .width(520)
        .padding({ left: 24, right: 24, top: 24, bottom: 24 })
        .backgroundColor('#FFFFFF')
        .borderRadius(28)
        .shadow({ radius: 30, color: '#33000000', offsetX: 0, offsetY: 10 })
      }
      .width('100%')
      .height('100%')
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row() {
        Column() {
          Scroll() {
            Column() {
              Text('我的笔记')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#707887')
                .width('100%')
                .margin({ left: 16, bottom: 12 })

              Column({ space: 8 }) {
                ForEach(this.menuItems, (item: AppMenuItem) => {
                  this.buildSidebarMenuItem(item)
                }, (item: AppMenuItem) => item.key)
              }
              .width('100%')
              .padding({ right: 10 })

              Text('文件夹')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#707887')
                .width('100%')
                .margin({ left: 16, top: 28, bottom: 12 })

              this.buildLeftFolderList()

              Text('新建文件夹')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2F6BFF')
                .margin({ left: 16, top: 18, bottom: 20 })
            }
            .width('100%')
            .height('100%')
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .padding({ top: 18, bottom: 12 })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        }
        .width('26%')
        .height('100%')
        .padding({ bottom: 8 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .backgroundColor('#F5F7FA')
        .border({
          width: { right: 1 },
          color: '#E7EBF0'
        })

        Column() {
          this.buildRightHeader()

          Scroll() {
            this.buildRightContentArea()
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        }
        .layoutWeight(1)
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .backgroundColor('#F8FAFC')
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)

      this.buildFolderActionDialog()
      this.buildSettingsDialog()
    }
    .width('100%')
    .height('100%')
  }
}
