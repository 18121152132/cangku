// 002 学分与毕业进度规划
// 维护已修课程/学分/先修；模拟不同学期修读方案并校验先修
import DataStore from '../model/DataStore';
import { TakenCourse, GradRequirement, SemesterPlan, PlanCourse } from '../model/types';
import { BackHeader, Field, EmptyHint, TagView, THEME, DialogShell } from '../components/Common';

@Entry
@Component
struct CreditPlanPage {
  @State taken: TakenCourse[] = [];
  @State grad: GradRequirement = { totalCredits: 150, major: '', categoryCredits: [] };
  @State semPlans: SemesterPlan[] = [];

  @State showTaken: boolean = false;
  @State tName: string = '';
  @State tCredit: string = '3';
  @State tSem: string = '2025-S1';
  @State tPre: string = '';

  @State showPlan: boolean = false;
  @State pName: string = '';

  @State showPlanCourse: boolean = false;
  @State planCoursePlanId: string = '';
  @State pcName: string = '';
  @State pcCredit: string = '3';
  @State pcPre: string = '';

  @State showGrad: boolean = false;
  @State gTotal: string = '150';
  @State gMajor: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.taken = DataStore.taken.slice();
    this.grad = DataStore.grad;
    this.semPlans = DataStore.semPlans.slice();
  }

  get takenCredits(): number {
    let s = 0;
    for (const t of this.taken) {
      s += t.credit;
    }
    return s;
  }

  get takenNames(): Set<string> {
    const set = new Set<string>();
    for (const t of this.taken) {
      set.add(t.name);
    }
    return set;
  }

  getPlanIssues(plan: SemesterPlan): string[] {
    const pool = new Set<string>(this.takenNames);
    const issues: string[] = [];
    for (const c of plan.courses) {
      for (const pr of c.prereq) {
        if (!pool.has(pr)) {
          issues.push(c.name + ' 缺先修『' + pr + '』');
        }
      }
      pool.add(c.name);
    }
    return issues;
  }

  planCredits(plan: SemesterPlan): number {
    let s = 0;
    for (const c of plan.courses) {
      s += c.credit;
    }
    return s;
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '学分与毕业进度规划', subtitle: '002 · 维护学分与模拟修读方案' })

        Scroll() {
          Column() {
            this.GradCard()
            this.TakenSection()
            this.PlanSection()
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

      // 对话框
      DialogShell({ visible: this.showTaken, title: '添加已修课程', onCancel: () => this.showTaken = false, child: this.TakenDialogContent })
      DialogShell({ visible: this.showPlan, title: '新建学期方案', onCancel: () => this.showPlan = false, child: this.PlanDialogContent })
      DialogShell({ visible: this.showPlanCourse, title: '添加方案课程', onCancel: () => this.showPlanCourse = false, child: this.PlanCourseDialogContent })
      DialogShell({ visible: this.showGrad, title: '编辑毕业要求', onCancel: () => this.showGrad = false, child: this.GradDialogContent })
    }
  }

  @Builder
  GradCard() {
    Column() {
      Row() {
        Column() {
          Text('已修学分')
            .fontSize(12).fontColor(THEME.subText)
          Text(this.takenCredits + ' / ' + this.grad.totalCredits)
            .fontSize(20).fontWeight(FontWeight.Bold).fontColor(THEME.primary)
        }
        .layoutWeight(1)
        Column() {
          Text('剩余学分')
            .fontSize(12).fontColor(THEME.subText)
          Text(Math.max(0, this.grad.totalCredits - this.takenCredits) + '')
            .fontSize(20).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        }
        .layoutWeight(1)
        Column() {
          Text('专业')
            .fontSize(12).fontColor(THEME.subText)
          Text(this.grad.major === '' ? '未设置' : this.grad.major)
            .fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        }
        .layoutWeight(1)
      }
      .width('100%')

      Progress({ value: this.grad.totalCredits === 0 ? 0 : Math.floor(this.takenCredits / this.grad.totalCredits * 100), total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(12)
        .margin({ top: 12 })
        .color(THEME.primary)
        .backgroundColor('#E8EBF2')

      Row() {
        Button('编辑毕业要求')
          .height(34).fontSize(13).backgroundColor('#EEF1F7').fontColor(THEME.text)
          .onClick(() => {
            this.gTotal = String(this.grad.totalCredits);
            this.gMajor = this.grad.major;
            this.showGrad = true;
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(THEME.card)
    .borderRadius(16)
    .margin({ bottom: 16 })
  }

  @Builder
  TakenSection() {
    Row() {
      Text('已修课程')
        .fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME.text)
      Button('+ 添加')
        .height(32).fontSize(13).backgroundColor(THEME.primary).fontColor('#FFFFFF')
        .margin({ left: 12 })
        .onClick(() => {
          this.tName = ''; this.tCredit = '3'; this.tSem = '2025-S1'; this.tPre = '';
          this.showTaken = true;
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .margin({ bottom: 10 })

    if (this.taken.length === 0) {
      EmptyHint({ text: '暂无已修课程' })
    } else {
      ForEach(this.taken, (t: TakenCourse) => {
        Row() {
          Column() {
            Text(t.name)
              .fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
            Row() {
              TagView({ text: t.credit + ' 学分', color: THEME.primary })
              if (t.semesterTaken !== '') {
                Text('· ' + t.semesterTaken)
                  .fontSize(12).fontColor(THEME.subText).margin({ left: 8 })
              }
            }
            .margin({ top: 6 })
            if (t.prereq.length > 0) {
              Text('先修: ' + t.prereq.join('、'))
                .fontSize(12).fontColor(THEME.warn).margin({ top: 4 })
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text('🗑')
            .fontSize(16).fontColor(THEME.subText).padding(8)
            .onClick(() => { DataStore.deleteTaken(t.id); this.refresh(); })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME.card)
        .borderRadius(12)
        .margin({ bottom: 8 })
      }, (t: TakenCourse) => t.id)
    }
  }

  @Builder
  PlanSection() {
    Row() {
      Text('学期修读方案（模拟）')
        .fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME.text)
      Button('+ 新建方案')
        .height(32).fontSize(13).backgroundColor(THEME.primary).fontColor('#FFFFFF')
        .margin({ left: 12 })
        .onClick(() => {
          this.pName = '';
          this.showPlan = true;
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .margin({ top: 8, bottom: 10 })

    if (this.semPlans.length === 0) {
      EmptyHint({ text: '暂无方案，点击新建' })
    } else {
      ForEach(this.semPlans, (p: SemesterPlan) => {
        Column() {
          Row() {
            Text(p.name)
              .fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
            Text('共 ' + this.planCredits(p) + ' 学分')
              .fontSize(12).fontColor(THEME.subText).margin({ left: 8 })
            Blank()
            Button('添加课程')
              .height(30).fontSize(12).backgroundColor('#EEF1F7').fontColor(THEME.text)
              .onClick(() => {
                this.planCoursePlanId = p.id;
                this.pcName = ''; this.pcCredit = '3'; this.pcPre = '';
                this.showPlanCourse = true;
              })
            Text('🗑')
              .fontSize(15).fontColor(THEME.subText).padding(6)
              .onClick(() => { DataStore.deleteSemPlan(p.id); this.refresh(); })
          }
          .width('100%')

          Progress({ value: 100, total: 100, type: ProgressType.Linear })
            .width('100%').height(6).color(THEME.success).backgroundColor('#E8EBF2')
            .margin({ top: 8 })

          if (p.courses.length === 0) {
            Text('尚未添加课程')
              .fontSize(12).fontColor(THEME.subText).margin({ top: 8 })
          } else {
            Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
              ForEach(p.courses, (c: PlanCourse, idx: number) => {
                Row() {
                  Text(c.name + ' · ' + c.credit)
                    .fontSize(12).fontColor(THEME.text)
                  Text('×')
                    .fontSize(12).fontColor(THEME.subText).margin({ left: 6 })
                    .onClick(() => { DataStore.removePlanCourse(p.id, idx); this.refresh(); })
                }
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor('#EEF1F7')
                .borderRadius(10)
                .margin({ right: 8, bottom: 8 })
              }, (c: PlanCourse, idx: number) => p.id + '_' + idx)
            }
            .width('100%')
            .margin({ top: 6 })
          }

          if (this.getPlanIssues(p).length > 0) {
            Column() {
              ForEach(this.getPlanIssues(p), (iss: string) => {
                Text('⚠ ' + iss)
                  .fontSize(12).fontColor(THEME.danger)
              }, (iss: string) => iss)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(8)
            .backgroundColor('#FF5A5F12')
            .borderRadius(8)
            .margin({ top: 8 })
          }
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME.card)
        .borderRadius(12)
        .margin({ bottom: 12 })
        .alignItems(HorizontalAlign.Start)
      }, (p: SemesterPlan) => p.id)
    }
  }

  @Builder
  TakenDialogContent() {
    Column() {
      Field('课程名称', this.tName, (v) => { this.tName = v; }, '如：数据结构')
      Field('学分', this.tCredit, (v) => { this.tCredit = v; }, '数字')
      Field('修读学期', this.tSem, (v) => { this.tSem = v; }, '如 2025-S1')
      Field('先修课程（逗号分隔）', this.tPre, (v) => { this.tPre = v; }, '选填，如 高数,线代')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showTaken = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.tName.trim() === '') {
              return;
            }
            const credit = Number(this.tCredit);
            DataStore.addTaken({
              name: this.tName.trim(),
              credit: isNaN(credit) ? 0 : credit,
              semesterTaken: this.tSem.trim(),
              prereq: this.tPre.split(/[,，]/).map((s) => s.trim()).filter((s) => s !== '')
            });
            this.showTaken = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  PlanDialogContent() {
    Column() {
      Field('方案名称', this.pName, (v) => { this.pName = v; }, '如：大二上')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showPlan = false; })
        Button('创建').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.pName.trim() === '') {
              return;
            }
            DataStore.addSemPlan({ id: '', name: this.pName.trim(), courses: [] });
            this.showPlan = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  PlanCourseDialogContent() {
    Column() {
      Field('课程名称', this.pcName, (v) => { this.pcName = v; }, '如：编译原理')
      Field('学分', this.pcCredit, (v) => { this.pcCredit = v; }, '数字')
      Field('先修课程（逗号分隔）', this.pcPre, (v) => { this.pcPre = v; }, '选填')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showPlanCourse = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.pcName.trim() === '') {
              return;
            }
            const credit = Number(this.pcCredit);
            DataStore.addPlanCourse(this.planCoursePlanId, {
              name: this.pcName.trim(),
              credit: isNaN(credit) ? 0 : credit,
              prereq: this.pcPre.split(/[,，]/).map((s) => s.trim()).filter((s) => s !== '')
            });
            this.showPlanCourse = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  GradDialogContent() {
    Column() {
      Field('专业名称', this.gMajor, (v) => { this.gMajor = v; }, '如：软件工程')
      Field('毕业总学分', this.gTotal, (v) => { this.gTotal = v; }, '数字')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showGrad = false; })
        Button('保存').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            const total = Number(this.gTotal);
            DataStore.setGrad({
              totalCredits: isNaN(total) ? 150 : total,
              major: this.gMajor.trim(),
              categoryCredits: this.grad.categoryCredits
            });
            this.showGrad = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }
}
