// 003 课程任务与截止日看板
// 三栏看板，支持拖拽/箭头调整状态；检测同日截止时间冲突
import DataStore from '../model/DataStore';
import { TaskCard, TaskStatus } from '../model/types';
import { BackHeader, Field, EmptyHint, THEME, DialogShell } from '../components/Common';
import { todayStr, daysUntil } from '../model/utils';

interface KanbanColumn {
  key: TaskStatus;
  label: string;
  color: string;
}

const COLUMNS: KanbanColumn[] = [
  { key: 'todo', label: '待办', color: '#FFB020' },
  { key: 'doing', label: '进行中', color: '#3A7AFE' },
  { key: 'done', label: '已完成', color: '#2EC4B6' }
];

@Entry
@Component
struct TaskBoardPage {
  @State tasks: TaskCard[] = [];
  @State dragId: string = '';
  @State showAdd: boolean = false;
  @State fTitle: string = '';
  @State fCourse: string = '';
  @State fDue: string = '';
  @State fPriority: number = 2;

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.tasks = DataStore.tasks.slice();
  }

  statusLabel(s: TaskStatus): string {
    for (const c of COLUMNS) {
      if (c.key === s) {
        return c.label;
      }
    }
    return '';
  }

  statusColor(s: TaskStatus): string {
    for (const c of COLUMNS) {
      if (c.key === s) {
        return c.color;
      }
    }
    return THEME.primary;
  }

  /** 检测同日截止（>=2 个任务同一天）的冲突任务 id */
  conflictTaskIds(): Set<string> {
    const byDate: Map<string, string[]> = new Map<string, string[]>();
    for (const t of this.tasks) {
      const arr = byDate.get(t.deadline);
      if (arr) {
        arr.push(t.id);
      } else {
        byDate.set(t.deadline, [t.id]);
      }
    }
    const conflict: Set<string> = new Set<string>();
    byDate.forEach((ids: string[]) => {
      if (ids.length >= 2) {
        ids.forEach((id: string) => conflict.add(id));
      }
    });
    return conflict;
  }

  moveTask(id: string, dir: number): void {
    const t = this.tasks.find((x) => x.id === id);
    if (!t) {
      return;
    }
    const idx = COLUMNS.findIndex((c) => c.key === t.status);
    const ni = idx + dir;
    if (ni < 0 || ni >= COLUMNS.length) {
      return;
    }
    DataStore.setTaskStatus(id, COLUMNS[ni].key);
    this.refresh();
  }

  get conflicts(): Set<string> {
    return this.conflictTaskIds();
  }

  colTasks(col: KanbanColumn): TaskCard[] {
    return this.tasks.filter((t) => t.status === col.key);
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '课程任务与截止日看板', subtitle: '003 · 拖拽安排并检查时间冲突' })

        if (this.conflicts.size > 0) {
          Row() {
            Text('⚠ 有 ' + this.conflicts.size + ' 个任务与同日其他任务截止冲突，注意排期')
              .fontSize(13).fontColor('#FFFFFF')
          }
          .width('100%').padding(10)
          .backgroundColor(THEME.danger)
          .padding({ left: 16, right: 16 })
        }

        Scroll() {
          Row() {
            ForEach(COLUMNS, (col: KanbanColumn) => {
              this.ColumnView(col, this.conflicts)
            }, (col: KanbanColumn) => col.key)
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

      Button('+ 新建任务')
        .width(120).height(44).borderRadius(22)
        .backgroundColor(THEME.primary).fontColor('#FFFFFF')
        .position({ right: 24, bottom: 24 })
        .onClick(() => {
          this.fTitle = ''; this.fCourse = ''; this.fDue = todayStr(); this.fPriority = 2;
          this.showAdd = true;
        })

      DialogShell({ visible: this.showAdd, title: '新建任务', onCancel: () => this.showAdd = false, child: this.AddDialogContent })
    }
  }

  @Builder
  ColumnView(col: KanbanColumn, conflicts: Set<string>) {
    Column() {
      Row() {
        Text(col.label)
          .fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        Text(String(this.colTasks(col).length))
          .fontSize(12).fontColor('#FFFFFF').backgroundColor(col.color)
          .padding({ left: 8, right: 8, top: 1, bottom: 1 }).borderRadius(8)
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.colTasks(col).length === 0) {
        Text('拖拽任务到此处')
          .fontSize(12).fontColor(THEME.subText)
          .width('100%').height(60)
          .textAlign(TextAlign.Center)
          .backgroundColor('#F0F2F7')
          .borderRadius(10)
          .border({ width: 1, color: THEME.border, style: BorderStyle.Dashed })
      } else {
        ForEach(this.colTasks(col), (t: TaskCard) => {
          this.TaskCardView(t, conflicts, col)
        }, (t: TaskCard) => t.id)
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
        DataStore.setTaskStatus(this.dragId, col.key);
        this.dragId = '';
        this.refresh();
      }
    })
  }

  @Builder
  TaskCardView(t: TaskCard, conflicts: Set<string>, col: KanbanColumn) {
    Column() {
      Text(t.title)
        .fontSize(14).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        .decoration({ type: t.status === 'done' ? TextDecorationType.LineThrough : TextDecorationType.None })
      Row() {
        if (t.course !== '') {
          Text(t.course)
            .fontSize(11).fontColor(THEME.subText)
        }
        Text('· 截止' + t.deadline)
          .fontSize(11)
          .fontColor(daysUntil(t.deadline) < 0 && t.status !== 'done' ? THEME.danger : THEME.subText)
          .margin({ left: 6 })
      }
      .margin({ top: 4 }).width('100%')
      if (conflicts.has(t.id)) {
        Text('同日截止冲突')
          .fontSize(10).fontColor(THEME.danger).margin({ top: 4 })
      }
      Row() {
        Button('←').width(28).height(24).fontSize(12).backgroundColor('#FFFFFF').fontColor(THEME.text)
          .onClick(() => this.moveTask(t.id, -1))
        Button('→').width(28).height(24).fontSize(12).backgroundColor('#FFFFFF').fontColor(THEME.text)
          .margin({ left: 6 })
          .onClick(() => this.moveTask(t.id, 1))
        Text('🗑').fontSize(14).fontColor(THEME.subText).padding(4).margin({ left: 6 })
          .onClick(() => { DataStore.deleteTask(t.id); this.refresh(); })
      }
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor(THEME.card)
    .borderRadius(10)
    .margin({ bottom: 10 })
    .border({ width: conflicts.has(t.id) ? 2 : 0, color: THEME.danger })
    .draggable(true)
    .onDragStart(() => {
      this.dragId = t.id;
    })
  }

  @Builder
  AddDialogContent() {
    Column() {
      Field('任务标题', this.fTitle, (v) => { this.fTitle = v; }, '如：完成实验报告')
      Field('关联课程', this.fCourse, (v) => { this.fCourse = v; }, '选填')
      Field('截止日期', this.fDue, (v) => { this.fDue = v; }, 'YYYY-MM-DD')
      Row() {
        Text('优先级')
          .fontSize(12).fontColor(THEME.subText).margin({ right: 8 })
        ForEach([1, 2, 3], (p: number) => {
          Button(p === 1 ? '低' : p === 2 ? '中' : '高')
            .height(32).fontSize(12)
            .backgroundColor(this.fPriority === p ? THEME.primary : '#EEF1F7')
            .fontColor(this.fPriority === p ? '#FFFFFF' : THEME.text)
            .margin({ left: 8 })
            .onClick(() => { this.fPriority = p; })
        }, (p: number) => String(p))
      }
      .width('100%').margin({ top: 10 })
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showAdd = false; })
        Button('创建').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.fTitle.trim() === '') {
              return;
            }
            DataStore.addTask({
              title: this.fTitle.trim(),
              course: this.fCourse.trim(),
              deadline: this.fDue.trim() === '' ? todayStr() : this.fDue.trim(),
              status: 'todo',
              priority: this.fPriority
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
