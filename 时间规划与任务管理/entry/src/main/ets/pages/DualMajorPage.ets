// 006 双专业修读路径规划
// 整合两个专业课程与重叠学分；按先修关系分层展示修读顺序与负担
import DataStore from '../model/DataStore';
import { Major, MajorCourse, CombinedCourse } from '../model/types';
import { BackHeader, EmptyHint, THEME, DialogShell, Field } from '../components/Common';

@Entry
@Component
struct DualMajorPage {
  @State majors: Major[] = [];
  @State showMajor: boolean = false;
  @State mName: string = '';
  @State showCourse: boolean = false;
  @State courseMajorId: string = '';
  @State cName: string = '';
  @State cCredit: string = '3';
  @State cPre: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.majors = DataStore.majors.slice();
  }

  allCourses(): CombinedCourse[] {
    const map: Map<string, CombinedCourse> = new Map<string, CombinedCourse>();
    for (const m of this.majors) {
      for (const c of m.requiredCourses) {
        const exist: CombinedCourse | undefined = map.get(c.name);
        if (exist) {
          exist.majors.push(m.name);
        } else {
          map.set(c.name, { name: c.name, credit: c.credit, prereq: c.prereq.slice(), majors: [m.name] });
        }
      }
    }
    const arr: CombinedCourse[] = [];
    map.forEach((v: CombinedCourse) => {
      arr.push(v);
    });
    return arr;
  }

  combinedCredits(): number {
    let s = 0;
    for (const m of this.majors) {
      for (const c of m.requiredCourses) {
        s += c.credit;
      }
    }
    return s;
  }

  uniqueCredits(): number {
    let s = 0;
    for (const c of this.allCourses()) {
      s += c.credit;
    }
    return s;
  }

  overlapNames(): string[] {
    const counts: Map<string, number> = new Map<string, number>();
    for (const m of this.majors) {
      for (const c of m.requiredCourses) {
        const cur: number | undefined = counts.get(c.name);
        counts.set(c.name, (cur ?? 0) + 1);
      }
    }
    const arr: string[] = [];
    counts.forEach((n: number, name: string) => {
      if (n >= 2) {
        arr.push(name);
      }
    });
    return arr;
  }

  levelMap(): Map<string, number> {
    const combined: CombinedCourse[] = this.allCourses();
    const prereqOf: Map<string, string[]> = new Map<string, string[]>();
    for (const c of combined) {
      prereqOf.set(c.name, c.prereq);
    }
    const memo: Map<string, number> = new Map<string, number>();
    const calc = (name: string): number => {
      const cached: number | undefined = memo.get(name);
      if (cached !== undefined) {
        return cached;
      }
      const pr: string[] = prereqOf.get(name) ?? [];
      let mx = -1;
      for (const p of pr) {
        if (prereqOf.get(p) !== undefined) {
          mx = Math.max(mx, calc(p));
        }
      }
      const lvl = mx + 1;
      memo.set(name, lvl);
      return lvl;
    };
    const res: Map<string, number> = new Map<string, number>();
    for (const c of combined) {
      res.set(c.name, calc(c.name));
    }
    return res;
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '双专业修读路径规划', subtitle: '006 · 重叠学分与修读顺序' })

        Scroll() {
          Column() {
            this.SummaryCard()
            this.MajorsSection()
            this.GraphSection()
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

      Button('+ 添加专业')
        .height(44).borderRadius(22).backgroundColor(THEME.primary).fontColor('#FFFFFF')
        .position({ right: 24, bottom: 24 })
        .onClick(() => {
          this.mName = '';
          this.showMajor = true;
        })

      DialogShell({ visible: this.showMajor, title: '添加专业', onCancel: () => this.showMajor = false, child: this.MajorDialogContent })
      DialogShell({ visible: this.showCourse, title: '添加课程到专业', onCancel: () => this.showCourse = false, child: this.CourseDialogContent })
    }
  }

  @Builder
  SummaryCard() {
    Row() {
      Column() {
        Text('合并学分').fontSize(12).fontColor(THEME.subText)
        Text(this.combinedCredits() + '').fontSize(20).fontWeight(FontWeight.Bold).fontColor(THEME.text)
      }
      .layoutWeight(1)
      Column() {
        Text('去重学分').fontSize(12).fontColor(THEME.subText)
        Text(this.uniqueCredits() + '').fontSize(20).fontWeight(FontWeight.Bold).fontColor(THEME.success)
      }
      .layoutWeight(1)
      Column() {
        Text('重叠省下').fontSize(12).fontColor(THEME.subText)
        Text((this.combinedCredits() - this.uniqueCredits()) + '').fontSize(20).fontWeight(FontWeight.Bold).fontColor(THEME.primary)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(THEME.card)
    .borderRadius(16)
    .margin({ bottom: 16 })

    if (this.overlapNames().length > 0) {
      Row() {
        Text('重叠课程：' + this.overlapNames().join('、'))
          .fontSize(12).fontColor(THEME.primary)
      }
      .width('100%').padding(10)
      .backgroundColor('#3A7AFE12').borderRadius(10)
      .margin({ bottom: 16 })
    }
  }

  @Builder
  MajorsSection() {
    Row() {
      Text('专业要求')
        .fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME.text)
    }
    .width('100%').margin({ bottom: 10 })

    if (this.majors.length === 0) {
      EmptyHint({ text: '暂无专业，点击右下角添加' })
    } else {
      ForEach(this.majors, (m: Major) => {
        Column() {
          Row() {
            Text(m.name)
              .fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
            Text('共 ' + m.requiredCourses.reduce((a, c) => a + c.credit, 0) + ' 学分')
              .fontSize(12).fontColor(THEME.subText).margin({ left: 8 })
            Blank()
            Button('+课')
              .height(28).fontSize(11).backgroundColor('#EEF1F7').fontColor(THEME.text)
              .onClick(() => {
                this.courseMajorId = m.id;
                this.cName = ''; this.cCredit = '3'; this.cPre = '';
                this.showCourse = true;
              })
            Text('🗑').fontSize(14).fontColor(THEME.subText).padding(4)
              .onClick(() => { DataStore.deleteMajor(m.id); this.refresh(); })
          }
          .width('100%')

          if (m.requiredCourses.length === 0) {
            Text('尚未添加课程').fontSize(12).fontColor(THEME.subText).margin({ top: 6 })
          } else {
            Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
              ForEach(m.requiredCourses, (c: MajorCourse) => {
                Column() {
                  Text(c.name).fontSize(12).fontColor(THEME.text)
                  Text(c.credit + '学分').fontSize(10).fontColor(THEME.subText).margin({ top: 2 })
                  if (c.prereq.length > 0) {
                    Text('需:' + c.prereq.join('/')).fontSize(9).fontColor(THEME.warn).margin({ top: 2 })
                  }
                }
                .padding(8)
                .backgroundColor('#EEF1F7')
                .borderRadius(10)
                .margin({ right: 8, bottom: 8 })
              }, (c: MajorCourse) => m.id + c.name)
            }
            .width('100%').margin({ top: 6 })
          }
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME.card)
        .borderRadius(12)
        .margin({ bottom: 12 })
        .alignItems(HorizontalAlign.Start)
      }, (m: Major) => m.id)
    }
  }

  get graphLevels(): Map<string, number> {
    return this.levelMap();
  }

  get graphMaxLvl(): number {
    let m = 0;
    this.graphLevels.forEach((v: number) => {
      if (v > m) {
        m = v;
      }
    });
    return m;
  }

  get graphIdxs(): number[] {
    const a: number[] = [];
    const n = this.graphMaxLvl;
    for (let i = 0; i <= n; i++) {
      a.push(i);
    }
    return a;
  }

  layerCourses(lvl: number): CombinedCourse[] {
    return this.allCourses().filter((c) => (this.graphLevels.get(c.name) ?? -1) === lvl);
  }

  @Builder
  GraphSection() {
    Text('修读顺序图（按先修关系分层）')
      .fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME.text)
      .width('100%').margin({ top: 8, bottom: 10 })

    if (this.majors.length === 0) {
      EmptyHint({ text: '暂无数据' })
    } else {
      Column() {
        ForEach(this.graphIdxs, (lvl: number) => {
          if (this.layerCourses(lvl).length === 0) {
            Text('')
          } else {
            Column() {
              Row() {
                Text('第 ' + (lvl + 1) + ' 层 · ' + this.layerCourses(lvl).reduce((a, c) => a + c.credit, 0) + ' 学分')
                  .fontSize(12).fontColor(THEME.subText)
              }
              .width('100%').margin({ bottom: 6 })
              Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                ForEach(this.layerCourses(lvl), (c: CombinedCourse) => {
                  Column() {
                    Text(c.name).fontSize(12).fontColor('#FFFFFF')
                    Text(c.credit + '').fontSize(10).fontColor('#FFFFFF').opacity(0.9).margin({ top: 2 })
                  }
                  .padding(8)
                  .backgroundColor(c.majors.length >= 2 ? THEME.primary : '#7C8AA5')
                  .borderRadius(10)
                  .margin({ right: 8, bottom: 8 })
                }, (c: CombinedCourse) => c.name)
              }
              .width('100%')
            }
            .width('100%')
            .margin({ bottom: 10 })
            .alignItems(HorizontalAlign.Start)
          }
        }, (lvl: number) => 'lvl' + lvl)
      }
      .width('100%')
      .padding(12)
      .backgroundColor(THEME.card)
      .borderRadius(12)
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  MajorDialogContent() {
    Column() {
      Field('专业名称', this.mName, (v) => { this.mName = v; }, '如：软件工程')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showMajor = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.mName.trim() === '') {
              return;
            }
            DataStore.addMajor({ name: this.mName.trim(), requiredCourses: [] });
            this.showMajor = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  CourseDialogContent() {
    Column() {
      Field('课程名称', this.cName, (v) => { this.cName = v; }, '如：数据结构')
      Field('学分', this.cCredit, (v) => { this.cCredit = v; }, '数字')
      Field('先修课程（逗号分隔，须为已列课程）', this.cPre, (v) => { this.cPre = v; }, '选填')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showCourse = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.cName.trim() === '') {
              return;
            }
            const major = this.majors.find((m) => m.id === this.courseMajorId);
            if (major) {
              const credit = Number(this.cCredit);
              major.requiredCourses.push({
                name: this.cName.trim(),
                credit: isNaN(credit) ? 0 : credit,
                prereq: this.cPre.split(/[,，]/).map((s) => s.trim()).filter((s) => s !== '')
              });
              DataStore.updateMajor(major);
            }
            this.showCourse = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }
}
