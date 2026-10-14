// 007 课程资料文件归档
// 按学期/课程整理课件、作业、参考资料；支持批量命名与拖入分类
import DataStore from '../model/DataStore';
import { ArchiveItem, CategoryDef } from '../model/types';
import { BackHeader, EmptyHint, THEME, DialogShell, Field } from '../components/Common';

const CATEGORIES: CategoryDef[] = [
  { key: '课件', color: '#3A7AFE' },
  { key: '作业', color: '#FFB020' },
  { key: '参考资料', color: '#2EC4B6' }
];

@Entry
@Component
struct ArchivePage {
  @State archive: ArchiveItem[] = [];
  @State dragId: string = '';
  @State showAdd: boolean = false;
  @State showBatch: boolean = false;
  @State aName: string = '';
  @State aSemester: string = '2026-S1';
  @State aCourse: string = '';
  @State aCategory: string = '课件';
  @State aNote: string = '';
  @State bNames: string = '';
  @State bSemester: string = '2026-S1';
  @State bCourse: string = '';
  @State bCategory: string = '课件';

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.archive = DataStore.archive.slice();
  }

  itemsOf(category: string): ArchiveItem[] {
    return this.archive.filter((a) => a.category === category)
      .sort((x, y) => x.semester.localeCompare(y.semester) || x.course.localeCompare(y.course));
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '课程资料文件归档', subtitle: '007 · 批量命名与拖入分类' })

        Row() {
          Button('+ 添加')
            .height(34).fontSize(13).backgroundColor(THEME.primary).fontColor('#FFFFFF')
            .onClick(() => {
              this.aName = ''; this.aSemester = '2026-S1'; this.aCourse = ''; this.aCategory = '课件'; this.aNote = '';
              this.showAdd = true;
            })
          Button('批量命名')
            .height(34).fontSize(13).backgroundColor('#EEF1F7').fontColor(THEME.text)
            .margin({ left: 12 })
            .onClick(() => {
              this.bNames = ''; this.bSemester = '2026-S1'; this.bCourse = ''; this.bCategory = '课件';
              this.showBatch = true;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })

        Scroll() {
          Row() {
            ForEach(CATEGORIES, (cat: CategoryDef) => {
              this.CategoryColumn(cat)
            }, (cat: CategoryDef) => cat.key)
          }
          .padding(16)
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(THEME.bg)

      DialogShell({ visible: this.showAdd, title: '添加资料', onCancel: () => this.showAdd = false, child: this.AddDialogContent })
      DialogShell({ visible: this.showBatch, title: '批量命名', onCancel: () => this.showBatch = false, child: this.BatchDialogContent })
    }
  }

  @Builder
  CategoryColumn(cat: CategoryDef) {
    Column() {
      Row() {
        Text(cat.key)
          .fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        Text(String(this.itemsOf(cat.key).length))
          .fontSize(12).fontColor('#FFFFFF').backgroundColor(cat.color)
          .padding({ left: 8, right: 8, top: 1, bottom: 1 }).borderRadius(8)
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.itemsOf(cat.key).length === 0) {
        Text('拖拽资料到此')
          .fontSize(12).fontColor(THEME.subText)
          .width('100%').height(80)
          .textAlign(TextAlign.Center)
          .backgroundColor('#F0F2F7').borderRadius(10)
          .border({ width: 1, color: THEME.border, style: BorderStyle.Dashed })
      } else {
        ForEach(this.itemsOf(cat.key), (a: ArchiveItem) => {
          Column() {
            Text(a.name)
              .fontSize(13).fontColor(THEME.text)
              .maxLines(2)
            Row() {
              Text(a.semester).fontSize(10).fontColor(THEME.subText)
              Text('·' + a.course).fontSize(10).fontColor(THEME.subText).margin({ left: 4 })
            }
            .margin({ top: 4 }).width('100%')
            if (a.note !== '') {
              Text(a.note).fontSize(10).fontColor(THEME.warn).margin({ top: 2 }).maxLines(1)
            }
            Text('🗑').fontSize(12).fontColor(THEME.subText)
              .alignSelf(ItemAlign.End).margin({ top: 2 })
              .onClick(() => { DataStore.deleteArchive(a.id); this.refresh(); })
          }
          .width('100%')
          .padding(10)
          .backgroundColor(THEME.card)
          .borderRadius(10)
          .margin({ bottom: 8 })
          .border({ width: 1, color: THEME.border })
          .draggable(true)
          .onDragStart(() => {
            this.dragId = a.id;
          })
        }, (a: ArchiveItem) => a.id)
      }
    }
    .width('33%')
    .padding(10)
    .backgroundColor('#EEF1F7')
    .borderRadius(14)
    .margin({ right: 12 })
    .alignItems(HorizontalAlign.Start)
    .onDrop(() => {
      if (this.dragId !== '') {
        const item = this.archive.find((x) => x.id === this.dragId);
        if (item && item.category !== cat.key) {
          item.category = cat.key;
          DataStore.updateArchive(item);
        }
        this.dragId = '';
        this.refresh();
      }
    })
  }

  @Builder
  AddDialogContent() {
    Column() {
      Field('资料名称', this.aName, (v) => { this.aName = v; }, '如：第3章PPT')
      Field('学期', this.aSemester, (v) => { this.aSemester = v; }, '如 2026-S1')
      Field('课程', this.aCourse, (v) => { this.aCourse = v; }, '如 高等数学')
      this.CatPicker()
      Field('备注', this.aNote, (v) => { this.aNote = v; }, '选填')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showAdd = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.aName.trim() === '') {
              return;
            }
            DataStore.addArchive({
              name: this.aName.trim(),
              semester: this.aSemester.trim(),
              course: this.aCourse.trim(),
              category: this.aCategory,
              note: this.aNote.trim()
            });
            this.showAdd = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  CatPicker() {
    Column() {
      Text('分类')
        .fontSize(12).fontColor(THEME.subText).alignSelf(ItemAlign.Start)
      Row() {
        ForEach(CATEGORIES, (cat: CategoryDef) => {
          Text(cat.key)
            .fontSize(12)
            .fontColor(this.aCategory === cat.key ? '#FFFFFF' : THEME.subText)
            .backgroundColor(this.aCategory === cat.key ? THEME.primary : '#EEF1F7')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(12)
            .margin({ right: 8, top: 6 })
            .onClick(() => { this.aCategory = cat.key; })
        }, (cat: CategoryDef) => cat.key)
      }
      .width('100%')
    }
    .width('100%')
    .margin({ top: 10 })
  }

  @Builder
  BatchDialogContent() {
    Column() {
      Text('每行一个名称，将统一使用下方学期/课程/分类')
        .fontSize(12).fontColor(THEME.subText)
      TextArea({ placeholder: '第1章PPT\n第2章PPT\n实验指导书' })
        .onChange((v: string) => { this.bNames = v; })
        .width('100%')
        .height(120)
        .backgroundColor('#F2F4F8')
        .borderRadius(8)
        .margin({ top: 8 })
      Field('学期', this.bSemester, (v) => { this.bSemester = v; }, '如 2026-S1')
      Field('课程', this.bCourse, (v) => { this.bCourse = v; }, '如 高等数学')
      this.CatPickerBatch()
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showBatch = false; })
        Button('批量创建').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            const lines = this.bNames.split('\n').map((s) => s.trim()).filter((s) => s !== '');
            if (lines.length === 0) {
              return;
            }
            for (const n of lines) {
              DataStore.addArchive({
                name: n,
                semester: this.bSemester.trim(),
                course: this.bCourse.trim(),
                category: this.bCategory,
                note: ''
              });
            }
            this.showBatch = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  CatPickerBatch() {
    Column() {
      Text('分类')
        .fontSize(12).fontColor(THEME.subText).alignSelf(ItemAlign.Start)
      Row() {
        ForEach(CATEGORIES, (cat: CategoryDef) => {
          Text(cat.key)
            .fontSize(12)
            .fontColor(this.bCategory === cat.key ? '#FFFFFF' : THEME.subText)
            .backgroundColor(this.bCategory === cat.key ? THEME.primary : '#EEF1F7')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(12)
            .margin({ right: 8, top: 6 })
            .onClick(() => { this.bCategory = cat.key; })
        }, (cat: CategoryDef) => cat.key)
      }
      .width('100%')
    }
    .width('100%')
    .margin({ top: 10 })
  }
}
