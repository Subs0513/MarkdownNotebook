import { router } from '@kit.ArkUI'

class AppMenuItem {
  key: string = ''
  title: string = ''
  count: number = 0
  iconText: string = ''

  constructor(key: string, title: string, count: number, iconText: string) {
    this.key = key
    this.title = title
    this.count = count
    this.iconText = iconText
  }
}

class AppFolderItem {
  key: string = ''
  title: string = ''
  count: number = 0

  constructor(key: string, title: string, count: number) {
    this.key = key
    this.title = title
    this.count = count
  }
}

class AppNoteItem {
  id: number = 0
  title: string = ''
  updateTime: string = ''
  favorite: boolean = false

  constructor(id: number, title: string, updateTime: string, favorite: boolean) {
    this.id = id
    this.title = title
    this.updateTime = updateTime
    this.favorite = favorite
  }
}

@Entry
@Component
struct Index {
  @State selectedMenuKey: string = 'recent'
  @State selectedFolderKey: string = ''
  @State folders: Array<AppFolderItem> = []
  @State noteItems: Array<AppNoteItem> = []

  private menuItems: Array<AppMenuItem> = [
    new AppMenuItem('all', '全部笔记', 0, '📄'),
    new AppMenuItem('recent', '最近笔记', 0, '🕘'),
    new AppMenuItem('favorite', '我的收藏', 0, '☆'),
    new AppMenuItem('deleted', '最近删除', 0, '🗑')
  ]

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

  private getMenuCountByKey(key: string): number {
    if (key === 'all') {
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

  private openEditor(): void {
    router.pushUrl({
      url: 'pages/EditorPage',
      params: {
        noteTitle: '未命名笔记',
        noteContent: ''
      }
    })
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

      Text(folder.count.toString())
        .fontSize(15)
        .fontColor('#7C8493')
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.isFolderSelected(folder.key) ? '#E7EEFF' : Color.Transparent)
    .borderRadius(14)
    .onClick(() => {
      this.selectedFolderKey = folder.key
      this.selectedMenuKey = ''
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
      .width(360)
      .height(52)
      .backgroundColor('#F1F3F6')
      .borderRadius(26)
      .margin({ right: 16 })

      Row() {
        Text('▦')
          .fontSize(24)
          .fontColor('#2D3138')
      }
      .width(52)
      .height(52)
      .borderRadius(26)
      .backgroundColor('#F1F3F6')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      Row() {
        Text('⋮')
          .fontSize(26)
          .fontColor('#2D3138')
      }
      .width(52)
      .height(52)
      .borderRadius(26)
      .backgroundColor('#F1F3F6')
      .justifyContent(FlexAlign.Center)
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
      this.openEditor()
    })
  }

  @Builder
  private buildEmptyState() {
    Column() {
      Text('还没有笔记')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2329')

      Text('点击上方“新建笔记”，开始创建你的第一篇 Markdown 笔记')
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
      router.pushUrl({
        url: 'pages/EditorPage',
        params: {
          noteTitle: item.title,
          noteContent: ''
        }
      })
    })
  }

  @Builder
  private buildLeftFolderList() {
    if (this.folders.length === 0) {
      Column() {
        Text('暂无文件夹')
          .fontSize(15)
          .fontColor('#98A1AE')
          .margin({ left: 16, top: 4 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    } else {
      Scroll() {
        Column({ space: 6 }) {
          ForEach(this.folders, (folder: AppFolderItem) => {
            this.buildFolderItem(folder)
          }, (folder: AppFolderItem) => folder.key)
        }
        .width('100%')
        .padding({ right: 10 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
  }

  @Builder
  private buildRightContentArea() {
    Column() {
      this.buildNewNoteCard()

      if (this.noteItems.length === 0) {
        this.buildEmptyState()
        Blank()
      } else {
        Scroll() {
          Column({ space: 18 }) {
            ForEach(this.noteItems, (item: AppNoteItem) => {
              this.buildNoteCard(item)
            }, (item: AppNoteItem) => item.id.toString())
          }
          .width('100%')
          .margin({ top: 18 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 28, right: 28, top: 8, bottom: 20 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  build() {
    Row() {
      Column() {
        Row() {
          this.buildSidebarTopButton()
          Blank()
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 18, bottom: 20 })

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
        this.buildRightContentArea()
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
  }
}