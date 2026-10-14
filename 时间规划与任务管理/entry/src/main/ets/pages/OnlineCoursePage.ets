// 009 线上课程学习进度台
// 汇总不同平台课程/章节/学习记录；多栏界面统一规划
import DataStore from '../model/DataStore';
import { OnlineCourse } from '../model/types';
import { BackHeader, EmptyHint, THEME, DialogShell, Field } from '../components/Common';

@Entry
@Component
struct OnlineCoursePage {
  @State online: OnlineCourse[] = [];
  @State showAdd: boolean = false;
  @State oPlatform: string = '';
  @State oName: string = '';
  @State oTotal: string = '10';
  @State oDone: string = '0';
  @State oNote: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.online = DataStore.online.slice();
  }

  platforms(): string[] {
    const set: Set<string> = new Set<string>();
    for (const c of this.online) {
      set.add(c.platform);
    }
    const arr: string[] = [];
    set.forEach((p: string) => {
      arr.push(p);
    });
    return arr;
  }

  coursesOf(platform: string): OnlineCourse[] {
    return this.online.filter((c) => c.platform === platform);
  }

  adjust(o: OnlineCourse, delta: number): void {
    o.completedChapters = Math.max(0, Math.min(o.totalChapters, o.completedChapters + delta));
    DataStore.updateOnline(o);
    this.refresh();
  }

  pct(o: OnlineCourse): number {
    if (o.totalChapters === 0) {
      return 0;
    }
    return Math.floor(o.completedChapters / o.totalChapters * 100);
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '线上课程学习进度台', subtitle: '009 · 多平台多栏规划' })

        Row() {
          Button('+ 添加课程')
            .height(34).fontSize(13).backgroundColor(THEME.primary).fontColor('#FFFFFF')
            .onClick(() => {
              this.oPlatform = ''; this.oName = ''; this.oTotal = '10'; this.oDone = '0'; this.oNote = '';
              this.showAdd = true;
            })
          Text('共 ' + this.online.length + ' 门课 · ' + this.platforms().length + ' 个平台')
            .fontSize(12).fontColor(THEME.subText).margin({ left: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })

        Scroll() {
          Column() {
            if (this.online.length === 0) {
              EmptyHint({ text: '暂无课程，点击添加' })
            } else {
              ForEach(this.platforms(), (p: string) => {
                this.PlatformBlock(p)
              }, (p: string) => p)
            }
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

      DialogShell({ visible: this.showAdd, title: '添加线上课程', onCancel: () => this.showAdd = false, child: this.AddDialogContent })
    }
  }

  @Builder
  PlatformBlock(p: string) {
    Column() {
      Row() {
        Text(p)
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        Text('· ' + this.coursesOf(p).length + ' 门')
          .fontSize(12).fontColor(THEME.subText).margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 10 })

      ForEach(this.coursesOf(p), (c: OnlineCourse) => {
        Row() {
          Progress({ value: c.completedChapters, total: c.totalChapters, type: ProgressType.Ring })
            .width(54).height(54)
            .color(THEME.primary)
          Column() {
            Text(c.name)
              .fontSize(14).fontWeight(FontWeight.Bold).fontColor(THEME.text)
            Text('已学 ' + c.completedChapters + ' / ' + c.totalChapters + ' 章（' + this.pct(c) + '%）')
              .fontSize(11).fontColor(THEME.subText).margin({ top: 2 })
            if (c.note !== '') {
              Text(c.note).fontSize(10).fontColor(THEME.warn).margin({ top: 2 }).maxLines(1)
            }
            Row() {
              Button('-').width(28).height(24).fontSize(12).backgroundColor('#EEF1F7').fontColor(THEME.text)
                .onClick(() => this.adjust(c, -1))
              Text('章节').fontSize(10).fontColor(THEME.subText).margin({ left: 6, right: 6 })
              Button('+').width(28).height(24).fontSize(12).backgroundColor('#EEF1F7').fontColor(THEME.text)
                .onClick(() => this.adjust(c, 1))
              Text('🗑').fontSize(14).fontColor(THEME.subText).padding(4).margin({ left: 10 })
                .onClick(() => { DataStore.deleteOnline(c.id); this.refresh(); })
            }
            .margin({ top: 6 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 10 })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME.card)
        .borderRadius(12)
        .margin({ bottom: 8 })
      }, (c: OnlineCourse) => c.id)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#EEF1F7')
    .borderRadius(14)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AddDialogContent() {
    Column() {
      Field('平台名称', this.oPlatform, (v) => { this.oPlatform = v; }, '如：中国大学MOOC')
      Field('课程名称', this.oName, (v) => { this.oName = v; }, '如：Python程序设计')
      Row() {
        Column() { Field('总章节', this.oTotal, (v) => { this.oTotal = v; }, '数字') }
          .layoutWeight(1)
        Column() { Field('已学章节', this.oDone, (v) => { this.oDone = v; }, '数字') }
          .layoutWeight(1).margin({ left: 8 })
      }
      .width('100%')
      Field('备注', this.oNote, (v) => { this.oNote = v; }, '选填')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showAdd = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.oPlatform.trim() === '' || this.oName.trim() === '') {
              return;
            }
            const total = Number(this.oTotal);
            const done = Number(this.oDone);
            DataStore.addOnline({
              platform: this.oPlatform.trim(),
              name: this.oName.trim(),
              totalChapters: isNaN(total) ? 0 : total,
              completedChapters: isNaN(done) ? 0 : Math.min(done, isNaN(total) ? 0 : total),
              note: this.oNote.trim()
            });
            this.showAdd = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }
}
