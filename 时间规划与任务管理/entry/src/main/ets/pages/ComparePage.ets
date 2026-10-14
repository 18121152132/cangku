// 004 选课方案对比器
// 维护候选课程；并排对比多套方案的学分、时间冲突与个人偏好匹配
import DataStore from '../model/DataStore';
import { CandidateCourse, ComparePlan, MatchResult } from '../model/types';
import { BackHeader, Field, EmptyHint, TagView, THEME, DialogShell } from '../components/Common';

const TAG_OPTIONS: string[] = ['核心', '兴趣', '实用', '轻松'];

@Entry
@Component
struct ComparePage {
  @State candidates: CandidateCourse[] = [];
  @State plans: ComparePlan[] = [];
  @State prefTags: string[] = ['核心'];
  @State showCand: boolean = false;
  @State cName: string = '';
  @State cTime: string = '';
  @State cCredit: string = '3';
  @State cTags: string[] = [];
  @State showPlan: boolean = false;
  @State pName: string = '';
  @State showPick: boolean = false;
  @State pickPlanId: string = '';
  @State pickSelected: string[] = [];

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.candidates = DataStore.candidates.slice();
    this.plans = DataStore.comparePlans.slice();
  }

  candidateById(id: string): CandidateCourse | undefined {
    return this.candidates.find((c) => c.id === id);
  }

  planCredit(plan: ComparePlan): number {
    let s = 0;
    for (const id of plan.courseIds) {
      const c = this.candidateById(id);
      if (c) {
        s += c.credit;
      }
    }
    return s;
  }

  planConflict(plan: ComparePlan): boolean {
    const times: Map<string, number> = new Map<string, number>();
    for (const id of plan.courseIds) {
      const c = this.candidateById(id);
      if (c) {
        const cur = times.get(c.time);
        times.set(c.time, (cur ?? 0) + 1);
      }
    }
    let conflict = false;
    times.forEach((n: number) => {
      if (n > 1) {
        conflict = true;
      }
    });
    return conflict;
  }

  planMatch(plan: ComparePlan): MatchResult {
    let matched = 0;
    let total = 0;
    for (const id of plan.courseIds) {
      const c = this.candidateById(id);
      if (c) {
        total++;
        if (c.tags.some((t) => this.prefTags.indexOf(t) >= 0)) {
          matched++;
        }
      }
    }
    return { matched: matched, total: total };
  }

  togglePref(tag: string): void {
    const i = this.prefTags.indexOf(tag);
    if (i >= 0) {
      this.prefTags.splice(i, 1);
    } else {
      this.prefTags.push(tag);
    }
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '选课方案对比器', subtitle: '004 · 并排对比时间/学分/偏好' })

        Scroll() {
          Column() {
            // 个人偏好
            Row() {
              Text('我的偏好（用于匹配评分）')
                .fontSize(14).fontWeight(FontWeight.Bold).fontColor(THEME.text)
              Blank()
              ForEach(TAG_OPTIONS, (tag: string) => {
                Text(tag)
                  .fontSize(12)
                  .fontColor(this.prefTags.indexOf(tag) >= 0 ? '#FFFFFF' : THEME.subText)
                  .backgroundColor(this.prefTags.indexOf(tag) >= 0 ? THEME.primary : '#EEF1F7')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(12)
                  .margin({ left: 6 })
                  .onClick(() => this.togglePref(tag))
              }, (tag: string) => tag)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(THEME.card)
            .borderRadius(12)
            .margin({ bottom: 16 })

            // 候选课程库
            Row() {
              Text('候选课程库')
                .fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME.text)
              Button('+ 添加课程')
                .height(32).fontSize(13).backgroundColor(THEME.primary).fontColor('#FFFFFF')
                .margin({ left: 12 })
                .onClick(() => {
                  this.cName = ''; this.cTime = ''; this.cCredit = '3'; this.cTags = [];
                  this.showCand = true;
                })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .margin({ bottom: 10 })

            if (this.candidates.length === 0) {
              EmptyHint({ text: '暂无候选课程' })
            } else {
              ForEach(this.candidates, (c: CandidateCourse) => {
                Row() {
                  Column() {
                    Text(c.name).fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
                    Text(c.time + ' · ' + c.credit + '学分')
                      .fontSize(12).fontColor(THEME.subText).margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Row() {
                    ForEach(c.tags, (t: string) => {
                      TagView({ text: t, color: THEME.primary })
                    }, (t: string) => t)
                  }
                  .margin({ right: 8 })
                  Text('🗑').fontSize(15).fontColor(THEME.subText).padding(6)
                    .onClick(() => { DataStore.deleteCandidate(c.id); this.refresh(); })
                }
                .width('100%')
                .padding(12)
                .backgroundColor(THEME.card)
                .borderRadius(12)
                .margin({ bottom: 8 })
              }, (c: CandidateCourse) => c.id)
            }

            // 对比方案
            Row() {
              Text('对比方案（并排）')
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
            .margin({ top: 16, bottom: 10 })

            if (this.plans.length === 0) {
              EmptyHint({ text: '暂无方案，点击新建' })
            } else {
              ForEach(this.plans, (p: ComparePlan) => {
                this.PlanCard(p)
              }, (p: ComparePlan) => p.id)
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

      DialogShell({ visible: this.showCand, title: '添加候选课程', onCancel: () => this.showCand = false, child: this.CandDialogContent })
      DialogShell({ visible: this.showPlan, title: '新建对比方案', onCancel: () => this.showPlan = false, child: this.PlanDialogContent })
      DialogShell({ visible: this.showPick, title: '选择方案课程', onCancel: () => this.showPick = false, child: this.PickDialogContent })
    }
  }

  @Builder
  PlanCard(p: ComparePlan) {
    Column() {
      Row() {
        Text(p.name).fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        Blank()
        Button('编辑课程')
          .height(30).fontSize(12).backgroundColor('#EEF1F7').fontColor(THEME.text)
          .onClick(() => {
            this.pickPlanId = p.id;
            this.pickSelected = p.courseIds.slice();
            this.showPick = true;
          })
        Text('🗑').fontSize(15).fontColor(THEME.subText).padding(6)
          .onClick(() => { DataStore.deleteComparePlan(p.id); this.refresh(); })
      }
      .width('100%')

      Row() {
        Column() {
          Text('总学分').fontSize(11).fontColor(THEME.subText)
          Text(this.planCredit(p) + '').fontSize(18).fontWeight(FontWeight.Bold).fontColor(THEME.primary)
        }
        .layoutWeight(1)
        Column() {
          Text('课程数').fontSize(11).fontColor(THEME.subText)
          Text(p.courseIds.length + '').fontSize(18).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        }
        .layoutWeight(1)
        Column() {
          Text('偏好匹配').fontSize(11).fontColor(THEME.subText)
          Text(this.planMatch(p).matched + '/' + this.planMatch(p).total)
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor(THEME.success)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 8 })

      if (this.planConflict(p)) {
        Text('⚠ 该方案存在时间冲突（同一时段多门课）')
          .fontSize(12).fontColor(THEME.danger)
          .width('100%').padding(6)
          .backgroundColor('#FF5A5F12').borderRadius(8)
          .margin({ top: 8 })
      }

      if (this.pickRows(p).length === 0) {
        Text('尚未选择课程')
          .fontSize(12).fontColor(THEME.subText).margin({ top: 8 })
      } else {
        Column() {
          ForEach(this.pickRows(p), (c: CandidateCourse) => {
            Row() {
              Text(c.name).fontSize(13).fontColor(THEME.text)
              Text(c.time).fontSize(11).fontColor(THEME.subText).margin({ left: 8 })
              Blank()
              Text(c.credit + '学分').fontSize(11).fontColor(THEME.primary)
            }
            .width('100%')
            .padding({ top: 4, bottom: 4 })
            .border({ width: { bottom: 1 }, color: THEME.border })
          }, (c: CandidateCourse) => c.id)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(THEME.card)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  pickRows(p: ComparePlan): CandidateCourse[] {
    const result: CandidateCourse[] = [];
    for (const id of p.courseIds) {
      const c = this.candidateById(id);
      if (c) {
        result.push(c);
      }
    }
    return result;
  }

  @Builder
  CandDialogContent() {
    Column() {
      Field('课程名称', this.cName, (v) => { this.cName = v; }, '如：编译原理')
      Field('上课时间', this.cTime, (v) => { this.cTime = v; }, '如：周一 3-4节')
      Field('学分', this.cCredit, (v) => { this.cCredit = v; }, '数字')
      Text('标签（点击选择）')
        .fontSize(12).fontColor(THEME.subText).margin({ top: 10 })
      Row() {
        ForEach(TAG_OPTIONS, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor(this.cTags.indexOf(tag) >= 0 ? '#FFFFFF' : THEME.subText)
            .backgroundColor(this.cTags.indexOf(tag) >= 0 ? THEME.primary : '#EEF1F7')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(12)
            .margin({ right: 8, top: 6 })
            .onClick(() => {
              const i = this.cTags.indexOf(tag);
              if (i >= 0) { this.cTags.splice(i, 1); } else { this.cTags.push(tag); }
            })
        }, (tag: string) => tag)
      }
      .width('100%')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showCand = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.cName.trim() === '' || this.cTime.trim() === '') {
              return;
            }
            const credit = Number(this.cCredit);
            DataStore.addCandidate({
              name: this.cName.trim(),
              time: this.cTime.trim(),
              credit: isNaN(credit) ? 0 : credit,
              tags: this.cTags.slice()
            });
            this.showCand = false;
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
      Field('方案名称', this.pName, (v) => { this.pName = v; }, '如：方案A 偏核心')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showPlan = false; })
        Button('创建').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.pName.trim() === '') {
              return;
            }
            DataStore.addComparePlan({ id: '', name: this.pName.trim(), courseIds: [] });
            this.showPlan = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  PickDialogContent() {
    Column() {
      if (this.candidates.length === 0) {
        Text('请先在上方添加候选课程')
          .fontSize(13).fontColor(THEME.subText)
      } else {
        Column() {
          ForEach(this.candidates, (c: CandidateCourse) => {
            Row() {
              Column() {
                Text(c.name).fontSize(14).fontColor(THEME.text)
                Text(c.time + ' · ' + c.credit + '学分')
                  .fontSize(11).fontColor(THEME.subText).margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Button(this.pickSelected.indexOf(c.id) >= 0 ? '✓ 已选' : '选择')
                .height(30).fontSize(12)
                .backgroundColor(this.pickSelected.indexOf(c.id) >= 0 ? THEME.primary : '#EEF1F7')
                .fontColor(this.pickSelected.indexOf(c.id) >= 0 ? '#FFFFFF' : THEME.text)
                .onClick(() => {
                  const i = this.pickSelected.indexOf(c.id);
                  if (i >= 0) { this.pickSelected.splice(i, 1); }
                  else { this.pickSelected.push(c.id); }
                })
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .border({ width: { bottom: 1 }, color: THEME.border })
          }, (c: CandidateCourse) => c.id)
        }
        .height(300)
      }
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showPick = false; })
        Button('保存').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            DataStore.setPlanCourses(this.pickPlanId, this.pickSelected);
            this.showPick = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }
}
