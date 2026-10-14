// 005 个人学习时间统计
// 桌面计时器记录各科投入时间；按学科统计与柱状分布
import DataStore from '../model/DataStore';
import { StudyRecord, SubjectTotal } from '../model/types';
import { BackHeader, EmptyHint, THEME, DialogShell, Field } from '../components/Common';
import { todayStr } from '../model/utils';

const BAR_COLORS: string[] = ['#3A7AFE', '#4ECDC4', '#FFD166', '#FF6B6B', '#A78BFA', '#2EC4B6', '#FF9F68'];

@Entry
@Component
struct StudyTimePage {
  @State records: StudyRecord[] = [];
  @State subject: string = '';
  @State seconds: number = 0;
  @State running: boolean = false;
  @State showNote: boolean = false;
  @State noteText: string = '';
  @State pendingMinutes: number = 0;
  timerId: number = 0;

  aboutToAppear(): void {
    this.refresh();
  }

  aboutToDisappear(): void {
    if (this.timerId !== 0) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }
  }

  refresh(): void {
    this.records = DataStore.study.slice();
  }

  startTimer(): void {
    if (this.running) {
      return;
    }
    this.running = true;
    this.timerId = setInterval(() => {
      this.seconds++;
    }, 1000);
  }

  stopTimer(): void {
    if (this.timerId !== 0) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }
    this.running = false;
    if (this.seconds >= 10) {
      this.pendingMinutes = Math.round(this.seconds / 60);
      this.noteText = '';
      this.showNote = true;
    } else {
      this.seconds = 0;
    }
  }

  resetTimer(): void {
    if (this.timerId !== 0) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }
    this.running = false;
    this.seconds = 0;
  }

  formatTime(): string {
    const m = Math.floor(this.seconds / 60);
    const s = this.seconds % 60;
    return String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
  }

  subjectTotals(): SubjectTotal[] {
    const map: Map<string, number> = new Map<string, number>();
    for (const r of this.records) {
      const cur: number | undefined = map.get(r.subject);
      map.set(r.subject, (cur ?? 0) + r.minutes);
    }
    const arr: SubjectTotal[] = [];
    map.forEach((minutes: number, subject: string) => {
      arr.push({ subject: subject, minutes: minutes });
    });
    arr.sort((a: SubjectTotal, b: SubjectTotal) => b.minutes - a.minutes);
    return arr;
  }

  totalMinutes(): number {
    let s = 0;
    for (const r of this.records) {
      s += r.minutes;
    }
    return s;
  }

  get statTotals(): SubjectTotal[] {
    return this.subjectTotals();
  }

  get statMax(): number {
    const t: SubjectTotal[] = this.statTotals;
    return t.length > 0 ? t[0].minutes : 0;
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '个人学习时间统计', subtitle: '005 · 桌面计时器与统计图' })

        Scroll() {
          Column() {
            this.TimerCard()
            this.StatCard()
            this.RecordSection()
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

      DialogShell({ visible: this.showNote, title: '保存学习记录', onCancel: () => {
        this.showNote = false;
        this.seconds = 0;
      }, child: this.NoteDialogContent })
    }
  }

  @Builder
  TimerCard() {
    Column() {
      Row() {
        Text('桌面计时器')
          .fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        if (this.running) {
          Text('● 计时中')
            .fontSize(12).fontColor(THEME.danger).margin({ left: 10 })
        }
      }
      .width('100%')

      Text(this.formatTime())
        .fontSize(48).fontWeight(FontWeight.Bold).fontColor(THEME.primary)
        .margin({ top: 12 })

      Field('学习科目', this.subject, (v) => { this.subject = v; }, '如：高等数学')

      Row() {
        Button(this.running ? '暂停' : '开始')
          .layoutWeight(1)
          .backgroundColor(this.running ? THEME.warn : THEME.primary)
          .fontColor('#FFFFFF')
          .onClick(() => {
            if (this.running) {
              this.stopTimer();
            } else {
              this.startTimer();
            }
          })
        Button('重置')
          .layoutWeight(1)
          .margin({ left: 12 })
          .backgroundColor('#F2F4F8')
          .fontColor(THEME.text)
          .onClick(() => this.resetTimer())
      }
      .margin({ top: 12 }).width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(THEME.card)
    .borderRadius(16)
    .margin({ bottom: 16 })
  }

  @Builder
  StatCard() {
    Column() {
      Row() {
        Column() {
          Text('总学习时长').fontSize(12).fontColor(THEME.subText)
          Text(Math.floor(this.totalMinutes() / 60) + 'h ' + (this.totalMinutes() % 60) + 'm')
            .fontSize(20).fontWeight(FontWeight.Bold).fontColor(THEME.primary)
        }
        .layoutWeight(1)
        Column() {
          Text('记录条数').fontSize(12).fontColor(THEME.subText)
          Text(this.records.length + '').fontSize(20).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        }
        .layoutWeight(1)
        Column() {
          Text('学科数').fontSize(12).fontColor(THEME.subText)
          Text(this.statTotals.length + '').fontSize(20).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        }
        .layoutWeight(1)
      }
      .width('100%')

      if (this.statTotals.length === 0) {
        Text('暂无统计数据')
          .fontSize(12).fontColor(THEME.subText).margin({ top: 10 })
      } else {
        Column() {
          ForEach(this.statTotals, (t: SubjectTotal, idx: number) => {
            Row() {
              Text(t.subject)
                .fontSize(12).fontColor(THEME.text)
                .width(90)
                .textAlign(TextAlign.End)
                .margin({ right: 8 })
              Stack({ alignContent: Alignment.Start }) {
                Row().height(16).width('100%').backgroundColor('#EEF1F7').borderRadius(8)
                Row().height(16)
                  .width((this.statMax === 0 ? 0 : Math.floor(t.minutes / this.statMax * 100)) + '%')
                  .backgroundColor(BAR_COLORS[idx % BAR_COLORS.length])
                  .borderRadius(8)
              }
              .layoutWeight(1)
              Text(t.minutes + 'm')
                .fontSize(12).fontColor(THEME.subText)
                .margin({ left: 8 })
                .width(50)
            }
            .width('100%')
            .margin({ top: 8 })
          }, (t: SubjectTotal, idx: number) => t.subject + idx)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(THEME.card)
    .borderRadius(16)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RecordSection() {
    Text('学习记录')
      .fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME.text)
      .width('100%').margin({ bottom: 10 })

    if (this.records.length === 0) {
      EmptyHint({ text: '暂无记录，开始计时吧' })
    } else {
      ForEach(this.records.slice().reverse(), (r: StudyRecord) => {
        Row() {
          Column() {
            Text(r.subject).fontSize(14).fontWeight(FontWeight.Bold).fontColor(THEME.text)
            Text(r.date + (r.note !== '' ? ' · ' + r.note : ''))
              .fontSize(11).fontColor(THEME.subText).margin({ top: 2 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text(r.minutes + ' 分钟')
            .fontSize(13).fontColor(THEME.primary)
          Text('🗑').fontSize(15).fontColor(THEME.subText).padding(6)
            .onClick(() => { DataStore.deleteStudy(r.id); this.refresh(); })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME.card)
        .borderRadius(12)
        .margin({ bottom: 8 })
      }, (r: StudyRecord) => r.id)
    }
  }

  @Builder
  NoteDialogContent() {
    Column() {
      Text('本次学习 ' + this.pendingMinutes + ' 分钟')
        .fontSize(14).fontColor(THEME.text)
      Field('科目', this.subject, (v) => { this.subject = v; }, '如：高等数学')
      Field('备注', this.noteText, (v) => { this.noteText = v; }, '选填')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showNote = false; this.seconds = 0; })
        Button('保存').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            DataStore.addStudy({
              subject: this.subject.trim() === '' ? '未命名' : this.subject.trim(),
              minutes: this.pendingMinutes,
              date: todayStr(),
              note: this.noteText.trim()
            });
            this.showNote = false;
            this.seconds = 0;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }
}
