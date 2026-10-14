// 008 学习目标周复盘
// 学期目标拆为每周行动，记录完成原因，生成可编辑复盘报告
import DataStore from '../model/DataStore';
import { WeeklyGoal, WeeklyAction, Completion } from '../model/types';
import { BackHeader, EmptyHint, THEME, DialogShell, Field } from '../components/Common';

@Entry
@Component
struct WeeklyReviewPage {
  @State goals: WeeklyGoal[] = [];
  @State showGoal: boolean = false;
  @State gSemester: string = '2026-S1';
  @State gGoal: string = '';
  @State showAction: boolean = false;
  @State actionGoalId: string = '';
  @State acWeek: string = '第1周';
  @State acAction: string = '';
  @State showReport: boolean = false;
  @State reportText: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.goals = DataStore.weeklyGoals.slice();
  }

  completion(g: WeeklyGoal): Completion {
    let done = 0;
    for (const a of g.actions) {
      if (a.done) {
        done++;
      }
    }
    return { done: done, total: g.actions.length };
  }

  buildReport(g: WeeklyGoal): string {
    const c: Completion = this.completion(g);
    let s = '【学习目标周复盘】\n';
    s += '学期：' + g.semester + '\n';
    s += '总目标：' + g.goal + '\n';
    s += '完成进度：' + c.done + ' / ' + c.total +
      '（' + (c.total === 0 ? 0 : Math.round(c.done / c.total * 100)) + '%）\n\n';
    if (g.actions.length === 0) {
      s += '（暂无周行动）\n';
    } else {
      for (const a of g.actions) {
        s += a.week + '：' + a.action + '\n';
        s += '   完成情况：' + (a.done ? '已完成' : '未完成') + '\n';
        s += '   原因：' + (a.reason === '' ? '（未填写）' : a.reason) + '\n';
      }
    }
    return s;
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '学习目标周复盘', subtitle: '008 · 拆周行动与可编辑报告' })

        Row() {
          Button('+ 新建目标')
            .height(34).fontSize(13).backgroundColor(THEME.primary).fontColor('#FFFFFF')
            .onClick(() => {
              this.gSemester = '2026-S1'; this.gGoal = '';
              this.showGoal = true;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })

        Scroll() {
          Column() {
            if (this.goals.length === 0) {
              EmptyHint({ text: '暂无目标，点击新建' })
            } else {
              ForEach(this.goals, (g: WeeklyGoal) => {
                this.GoalCard(g)
              }, (g: WeeklyGoal) => g.id)
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

      DialogShell({ visible: this.showGoal, title: '新建学期目标', onCancel: () => this.showGoal = false, child: this.GoalDialogContent })
      DialogShell({ visible: this.showAction, title: '添加每周行动', onCancel: () => this.showAction = false, child: this.ActionDialogContent })
      DialogShell({ visible: this.showReport, title: '复盘报告（可编辑）', onCancel: () => this.showReport = false, child: this.ReportDialogContent })
    }
  }

  @Builder
  GoalCard(g: WeeklyGoal) {
    Column() {
      Row() {
        Column() {
          Text(g.semester).fontSize(12).fontColor(THEME.subText)
          Text(g.goal).fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('🗑').fontSize(15).fontColor(THEME.subText).padding(6)
          .onClick(() => { DataStore.deleteWeeklyGoal(g.id); this.refresh(); })
      }
      .width('100%')

      Row() {
        Text('完成 ' + this.completion(g).done + '/' + this.completion(g).total)
          .fontSize(12).fontColor(THEME.subText)
        Text('生成报告')
          .fontSize(12).fontColor(THEME.primary)
          .margin({ left: 16 })
          .onClick(() => {
            this.reportText = this.buildReport(g);
            this.showReport = true;
          })
        Text('+ 行动')
          .fontSize(12).fontColor(THEME.primary)
          .margin({ left: 16 })
          .onClick(() => {
            this.actionGoalId = g.id;
            this.acWeek = '第' + (g.actions.length + 1) + '周';
            this.acAction = '';
            this.showAction = true;
          })
      }
      .width('100%')
      .margin({ top: 6 })

      if (g.actions.length === 0) {
        Text('尚未添加每周行动')
          .fontSize(12).fontColor(THEME.subText).margin({ top: 6 })
      } else {
        Column() {
          ForEach(g.actions, (a: WeeklyAction) => {
            Row() {
              Text(a.done ? '✓' : '○')
                .fontSize(16)
                .fontColor(a.done ? THEME.success : THEME.subText)
                .width(28)
                .onClick(() => {
                  a.done = !a.done;
                  DataStore.updateWeeklyGoal(g);
                  this.refresh();
                })
              Column() {
                Row() {
                  Text(a.week).fontSize(11).fontColor(THEME.primary).width(48)
                  Text(a.action).fontSize(13).fontColor(THEME.text)
                }
                .width('100%')
                TextInput({ placeholder: '完成原因（可选）', text: a.reason })
                  .onChange((v: string) => {
                    a.reason = v;
                    DataStore.updateWeeklyGoal(g);
                  })
                  .width('100%')
                  .height(32)
                  .fontSize(12)
                  .backgroundColor('#F2F4F8')
                  .borderRadius(6)
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 6 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
            .border({ width: { bottom: 1 }, color: THEME.border })
          }, (a: WeeklyAction) => a.id)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 6 })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(THEME.card)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  GoalDialogContent() {
    Column() {
      Field('学期', this.gSemester, (v) => { this.gSemester = v; }, '如 2026-S1')
      Field('学期目标', this.gGoal, (v) => { this.gGoal = v; }, '如：绩点达到 3.8')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showGoal = false; })
        Button('创建').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.gGoal.trim() === '') {
              return;
            }
            DataStore.addWeeklyGoal({
              semester: this.gSemester.trim(),
              goal: this.gGoal.trim(),
              actions: []
            });
            this.showGoal = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  ActionDialogContent() {
    Column() {
      Field('周次', this.acWeek, (v) => { this.acWeek = v; }, '如 第3周')
      Field('行动内容', this.acAction, (v) => { this.acAction = v; }, '如：完成高数复习')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showAction = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.acAction.trim() === '') {
              return;
            }
            const g = this.goals.find((x) => x.id === this.actionGoalId);
            if (g) {
              g.actions.push({
                id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
                week: this.acWeek.trim(),
                action: this.acAction.trim(),
                done: false,
                reason: ''
              });
              DataStore.updateWeeklyGoal(g);
            }
            this.showAction = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  ReportDialogContent() {
    Column() {
      TextArea({ text: this.reportText })
        .onChange((v: string) => { this.reportText = v; })
        .width('100%')
        .height(320)
        .backgroundColor('#F2F4F8')
        .borderRadius(8)
        .fontSize(13)
      Button('完成')
        .width('100%')
        .margin({ top: 12 })
        .backgroundColor(THEME.primary)
        .fontColor('#FFFFFF')
        .onClick(() => { this.showReport = false; })
    }
    .width('100%')
  }
}
