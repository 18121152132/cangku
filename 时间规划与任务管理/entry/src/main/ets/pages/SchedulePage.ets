// 001 学期课表与冲突检测
// 录入/编辑课程，自动标记时间冲突；周视图 + 待办分屏
import DataStore from '../model/DataStore';
import { Course, Todo, CourseInput, COURSE_COLORS, WeekDay } from '../model/types';
import { findConflictIds, isValidTime, dayToChinese, todayStr, daysUntil } from '../model/utils';
import { BackHeader, EmptyHint, THEME } from '../components/Common';

const DAYS: WeekDay[] = [1, 2, 3, 4, 5, 6, 7];

@Entry
@Component
struct SchedulePage {
  @State courses: Course[] = [];
  @State todos: Todo[] = [];
  @State conflictIds: Set<string> = new Set<string>();
  @State showDialog: boolean = false;
  @State showTodoDialog: boolean = false;
  @State editingId: string = '';
  @State tTitle: string = '';
  @State tCourse: string = '';
  @State tDue: string = '';
  @State fName: string = '';
  @State fTeacher: string = '';
  @State fLocation: string = '';
  @State fDay: WeekDay = 1;
  @State fStart: string = '08:00';
  @State fEnd: string = '09:40';
  @State fCredit: string = '3';
  @State fColor: string = COURSE_COLORS[0];
  @State fSemester: string = '2026-S1';
  @State timeError: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.courses = DataStore.courses.slice();
    this.todos = DataStore.todos.slice();
    this.conflictIds = findConflictIds(this.courses);
  }

  openAdd(): void {
    this.editingId = '';
    this.fName = '';
    this.fTeacher = '';
    this.fLocation = '';
    this.fDay = 1;
    this.fStart = '08:00';
    this.fEnd = '09:40';
    this.fCredit = '3';
    this.fColor = COURSE_COLORS[0];
    this.fSemester = '2026-S1';
    this.timeError = '';
    this.showDialog = true;
  }

  openEdit(c: Course): void {
    this.editingId = c.id;
    this.fName = c.name;
    this.fTeacher = c.teacher;
    this.fLocation = c.location;
    this.fDay = c.day;
    this.fStart = c.start;
    this.fEnd = c.end;
    this.fCredit = String(c.credit);
    this.fColor = c.color;
    this.fSemester = c.semester;
    this.timeError = '';
    this.showDialog = true;
  }

  save(): void {
    if (this.fName.trim() === '') {
      this.timeError = '请填写课程名称';
      return;
    }
    if (!isValidTime(this.fStart) || !isValidTime(this.fEnd)) {
      this.timeError = '时间格式应为 HH:mm';
      return;
    }
    if (this.fStart >= this.fEnd) {
      this.timeError = '结束时间须晚于开始时间';
      return;
    }
    const credit = Number(this.fCredit);
    const draft: CourseInput = {
      name: this.fName.trim(),
      teacher: this.fTeacher.trim(),
      location: this.fLocation.trim(),
      day: this.fDay,
      start: this.fStart,
      end: this.fEnd,
      color: this.fColor,
      credit: isNaN(credit) ? 0 : credit,
      semester: this.fSemester.trim()
    };
    if (this.editingId !== '') {
      const old = this.courses.find((x) => x.id === this.editingId);
      if (old) {
        const updated: Course = {
          id: old.id,
          name: draft.name,
          teacher: draft.teacher,
          location: draft.location,
          day: draft.day,
          start: draft.start,
          end: draft.end,
          color: draft.color,
          credit: draft.credit,
          semester: draft.semester
        };
        DataStore.updateCourse(updated);
      }
    } else {
      DataStore.addCourse(draft);
    }
    this.showDialog = false;
    this.refresh();
  }

  openAddTodo(): void {
    this.tTitle = '';
    this.tCourse = '';
    this.tDue = todayStr();
    this.showTodoDialog = true;
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '学期课表与冲突检测', subtitle: '001 · 周视图 + 待办分屏' })

        if (this.conflictIds.size > 0) {
          Row() {
            Text('⚠ 检测到 ' + (this.conflictIds.size) + ' 门课程存在时间冲突')
              .fontSize(13)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding(10)
          .backgroundColor(THEME.danger)
          .padding({ left: 16, right: 16 })
        }

        // 分屏：左周视图，右待办
        Row() {
          // 周视图
          Column() {
            Text('周视图')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(THEME.text)
              .margin({ left: 16, bottom: 8 })
            if (this.courses.length === 0) {
              EmptyHint({ text: '暂无课程，点击右下角添加' })
            } else {
              Scroll() {
                Row() {
                  ForEach(DAYS, (d: WeekDay) => {
                    this.DayColumn(d)
                  }, (d: WeekDay) => String(d))
                }
                .padding(8)
              }
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(THEME.card)
          .borderRadius(16)
          .margin({ left: 16, top: 8, bottom: 16 })
          .padding({ top: 8 })

          // 待办
          Column() {
            Row() {
              Text('待办事项')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(THEME.text)
              Button('+')
                .width(30).height(30).borderRadius(15)
                .backgroundColor(THEME.primary)
                .fontColor('#FFFFFF')
                .margin({ left: 8 })
                .onClick(() => this.openAddTodo())
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .margin({ right: 16, bottom: 8 })

            if (this.todos.length === 0) {
              EmptyHint({ text: '暂无待办' })
            } else {
              Scroll() {
                Column() {
                  ForEach(this.todos, (t: Todo) => {
                    this.TodoItem(t)
                  }, (t: Todo) => t.id)
                }
                .padding(8)
              }
            }
          }
          .width(320)
          .backgroundColor(THEME.card)
          .borderRadius(16)
          .margin({ right: 16, top: 8, bottom: 16 })
          .padding({ top: 8 })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(THEME.bg)

      // 课程添加/编辑对话框
      if (this.showDialog) {
        this.CourseDialog()
      }
      // 待办添加对话框
      if (this.showTodoDialog) {
        this.TodoDialog()
      }
    }
  }

  dayCoursesOf(d: WeekDay): Course[] {
    return this.courses.filter((c) => c.day === d).sort((a, b) => a.start.localeCompare(b.start));
  }

  @Builder
  DayColumn(d: WeekDay) {
    Column() {
      Text(dayToChinese(d))
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME.text)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding(6)
        .backgroundColor(THEME.bg)
        .borderRadius(8)
      if (this.dayCoursesOf(d).length === 0) {
        Text('—')
          .fontSize(12)
          .fontColor(THEME.subText)
          .margin({ top: 20 })
      } else {
        ForEach(this.dayCoursesOf(d), (c: Course) => {
          Column() {
            Text(c.name)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(2)
            Text(c.start + '\n' + c.end)
              .fontSize(10)
              .fontColor('#FFFFFF')
              .opacity(0.9)
              .margin({ top: 4 })
            if (c.location !== '') {
              Text(c.location)
                .fontSize(10)
                .fontColor('#FFFFFF')
                .opacity(0.85)
                .margin({ top: 2 })
            }
          }
          .width('100%')
          .padding(8)
          .backgroundColor(c.color)
          .borderRadius(10)
          .margin({ top: 8 })
          .border({ width: this.conflictIds.has(c.id) ? 2 : 0, color: THEME.danger })
          .onClick(() => this.openEdit(c))
        }, (c: Course) => c.id)
      }
    }
    .width(120)
    .margin({ right: 8 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  TodoItem(t: Todo) {
    Row() {
      Column() {
        Text(t.title)
          .fontSize(13)
          .fontColor(t.done ? THEME.subText : THEME.text)
          .decoration({ type: t.done ? TextDecorationType.LineThrough : TextDecorationType.None })
        Row() {
          Text(t.course)
            .fontSize(11)
            .fontColor(THEME.subText)
            .margin({ right: 8 })
          Text('截止 ' + t.due)
            .fontSize(11)
            .fontColor(daysUntil(t.due) < 0 && !t.done ? THEME.danger : THEME.subText)
        }
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => { DataStore.toggleTodo(t.id); this.refresh(); })
      Text('🗑')
        .fontSize(14)
        .fontColor(THEME.subText)
        .padding(6)
        .onClick(() => { DataStore.deleteTodo(t.id); this.refresh(); })
    }
    .width('100%')
    .padding(10)
    .backgroundColor(THEME.bg)
    .borderRadius(10)
    .margin({ bottom: 8 })
  }

  @Builder
  CourseDialog() {
    Stack() {
      Column() { }.width('100%').height('100%')
        .backgroundColor('#00000050')
        .onClick(() => { this.showDialog = false; })
      Column() {
        Text(this.editingId === '' ? '添加课程' : '编辑课程')
          .fontSize(18).fontWeight(FontWeight.Bold).fontColor(THEME.text)
          .margin({ bottom: 12 })
        this.Field('课程名称', this.fName, (v) => { this.fName = v; }, '如：高等数学')
        this.Field('教师', this.fTeacher, (v) => { this.fTeacher = v; }, '选填')
        this.Field('地点', this.fLocation, (v) => { this.fLocation = v; }, '选填')
        // 星期选择
        Text('星期')
          .fontSize(12).fontColor(THEME.subText).margin({ top: 8 })
        Row() {
          ForEach(DAYS, (d: WeekDay) => {
            Button(dayToChinese(d).slice(2))
              .width(38).height(34).borderRadius(8)
              .fontSize(12)
              .backgroundColor(this.fDay === d ? THEME.primary : '#EEF1F7')
              .fontColor(this.fDay === d ? '#FFFFFF' : THEME.text)
              .onClick(() => { this.fDay = d; })
          }, (d: WeekDay) => String(d))
        }
        .width('100%').margin({ top: 6 }).justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Column() { this.Field('开始', this.fStart, (v) => { this.fStart = v; }, 'HH:mm') }.layoutWeight(1)
          Column() { this.Field('结束', this.fEnd, (v) => { this.fEnd = v; }, 'HH:mm') }
            .layoutWeight(1).margin({ left: 8 })
        }
        .width('100%').margin({ top: 8 })
        this.Field('学分', this.fCredit, (v) => { this.fCredit = v; }, '数字')
        this.Field('学期', this.fSemester, (v) => { this.fSemester = v; }, '如 2026-S1')
        // 颜色
        Text('颜色')
          .fontSize(12).fontColor(THEME.subText).margin({ top: 8 })
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
          ForEach(COURSE_COLORS, (col: string) => {
            Column() { }.width(26).height(26).borderRadius(13)
              .backgroundColor(col)
              .border({ width: this.fColor === col ? 3 : 0, color: THEME.text })
              .margin({ right: 8, bottom: 8 })
              .onClick(() => { this.fColor = col; })
          }, (col: string) => col)
        }
        .width('100%').margin({ top: 6 })
        if (this.timeError !== '') {
          Text(this.timeError).fontSize(12).fontColor(THEME.danger).margin({ top: 6 })
        }
        Row() {
          Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
            .onClick(() => { this.showDialog = false; })
          Button('保存').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
            .onClick(() => this.save())
        }
        .margin({ top: 16 }).width('100%')
      }
      .width('70%').constraintSize({ maxHeight: '90%' })
      .padding(20).backgroundColor(THEME.card).borderRadius(16)
      .shadow({ radius: 16, color: '#00000020', offsetY: 6 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%').height('100%').align(Alignment.Center)
  }

  @Builder
  TodoDialog() {
    Stack() {
      Column() { }.width('100%').height('100%')
        .backgroundColor('#00000050')
        .onClick(() => { this.showTodoDialog = false; })
      Column() {
        Text('添加待办')
          .fontSize(18).fontWeight(FontWeight.Bold).fontColor(THEME.text).margin({ bottom: 12 })
        this.Field('待办内容', this.tTitle, (v) => { this.tTitle = v; }, '如：完成实验报告')
        this.Field('关联课程', this.tCourse, (v) => { this.tCourse = v; }, '选填')
        this.Field('截止日期', this.tDue, (v) => { this.tDue = v; }, 'YYYY-MM-DD')
        Row() {
          Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
            .onClick(() => { this.showTodoDialog = false; })
          Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
            .onClick(() => {
              if (this.tTitle.trim() === '') {
                return;
              }
              DataStore.addTodo({
                title: this.tTitle.trim(),
                course: this.tCourse.trim(),
                due: this.tDue.trim() === '' ? todayStr() : this.tDue.trim(),
                done: false
              });
              this.showTodoDialog = false;
              this.refresh();
            })
        }
        .margin({ top: 16 }).width('100%')
      }
      .width('70%').padding(20).backgroundColor(THEME.card).borderRadius(16)
      .shadow({ radius: 16, color: '#00000020', offsetY: 6 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%').height('100%').align(Alignment.Center)
  }

  @Builder
  Field(label: string, value: string, onChange: (v: string) => void, placeholder: string) {
    Column() {
      Text(label)
        .fontSize(12).fontColor(THEME.subText)
      TextInput({ placeholder: placeholder, text: value })
        .onChange((v: string) => onChange(v))
        .width('100%').height(40)
        .backgroundColor('#F2F4F8').borderRadius(8)
        .margin({ top: 4 })
    }
    .width('100%').margin({ top: 10 })
    .alignItems(HorizontalAlign.Start)
  }
}
