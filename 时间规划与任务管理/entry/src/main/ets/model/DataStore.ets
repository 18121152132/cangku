// 本地数据持久层（基于 @ohos.data.preferences）
// 单例模式：所有页面共享同一份内存数据，并在变更时写入本地偏好存储。
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import {
  Course, CourseInput, Todo, TodoInput,
  TakenCourse, TakenInput, GradRequirement, CategoryCredit,
  SemesterPlan, PlanCourse,
  TaskCard, TaskInput, TaskStatus,
  CandidateCourse, CandidateInput, ComparePlan,
  StudyRecord, StudyInput,
  Major, MajorInput, MajorCourse,
  ArchiveItem, ArchiveInput,
  WeeklyGoal, WeeklyGoalInput, WeeklyAction,
  OnlineCourse, OnlineInput,
  MentorItem, MentorInput,
  STORE_KEYS, COURSE_COLORS
} from './types';
import { genId, todayStr } from './utils';

class DataStore {
  private static _instance: DataStore | undefined = undefined;
  private pref: preferences.Preferences | undefined = undefined;
  private initialized: boolean = false;

  // ===== 各模块数据集合 =====
  courses: Course[] = [];
  todos: Todo[] = [];
  taken: TakenCourse[] = [];
  grad: GradRequirement = {
    totalCredits: 150,
    major: '软件工程',
    categoryCredits: []
  };
  semPlans: SemesterPlan[] = [];
  tasks: TaskCard[] = [];
  candidates: CandidateCourse[] = [];
  comparePlans: ComparePlan[] = [];
  study: StudyRecord[] = [];
  majors: Major[] = [];
  archive: ArchiveItem[] = [];
  weeklyGoals: WeeklyGoal[] = [];
  online: OnlineCourse[] = [];
  mentor: MentorItem[] = [];

  static getInstance(): DataStore {
    if (!DataStore._instance) {
      DataStore._instance = new DataStore();
    }
    return DataStore._instance;
  }

  /** 在 Ability 启动时调用，传入 UIAbilityContext */
  init(ctx: common.Context): void {
    if (this.initialized) {
      return;
    }
    try {
      this.pref = preferences.getPreferencesSync(ctx, { name: 'StudyPlannerDB' });
      this.loadAll();
      if (!this.getFlag(STORE_KEYS.seeded)) {
        this.seed();
        this.setFlag(STORE_KEYS.seeded, true);
      }
    } catch (e) {
      // 偏好初始化失败则仅使用内存数据，不影响界面运行
    }
    this.initialized = true;
  }

  // ===== 底层读写 =====
  private getStr(key: string): string {
    if (!this.pref) {
      return '';
    }
    return this.pref.getSync(key, '') as string;
  }

  private setStr(key: string, val: string): void {
    if (!this.pref) {
      return;
    }
    this.pref.putSync(key, val);
    this.pref.flush();
  }

  private getFlag(key: string): boolean {
    if (!this.pref) {
      return false;
    }
    return this.pref.getSync(key, false) as boolean;
  }

  private setFlag(key: string, val: boolean): void {
    if (!this.pref) {
      return;
    }
    this.pref.putSync(key, val);
    this.pref.flush();
  }

  private loadList<T>(key: string): T[] {
    const s = this.getStr(key);
    if (!s) {
      return [];
    }
    try {
      return JSON.parse(s) as T[];
    } catch (e) {
      return [];
    }
  }

  private saveAll(): void {
    this.setStr(STORE_KEYS.courses, JSON.stringify(this.courses));
    this.setStr(STORE_KEYS.todos, JSON.stringify(this.todos));
    this.setStr(STORE_KEYS.taken, JSON.stringify(this.taken));
    this.setStr(STORE_KEYS.grad, JSON.stringify(this.grad));
    this.setStr(STORE_KEYS.semPlans, JSON.stringify(this.semPlans));
    this.setStr(STORE_KEYS.tasks, JSON.stringify(this.tasks));
    this.setStr(STORE_KEYS.candidates, JSON.stringify(this.candidates));
    this.setStr(STORE_KEYS.comparePlans, JSON.stringify(this.comparePlans));
    this.setStr(STORE_KEYS.study, JSON.stringify(this.study));
    this.setStr(STORE_KEYS.majors, JSON.stringify(this.majors));
    this.setStr(STORE_KEYS.archive, JSON.stringify(this.archive));
    this.setStr(STORE_KEYS.weeklyGoals, JSON.stringify(this.weeklyGoals));
    this.setStr(STORE_KEYS.online, JSON.stringify(this.online));
    this.setStr(STORE_KEYS.mentor, JSON.stringify(this.mentor));
  }

  private loadAll(): void {
    this.courses = this.loadList<Course>(STORE_KEYS.courses);
    this.todos = this.loadList<Todo>(STORE_KEYS.todos);
    this.taken = this.loadList<TakenCourse>(STORE_KEYS.taken);
    const g = this.getStr(STORE_KEYS.grad);
    if (g) {
      try {
        this.grad = JSON.parse(g) as GradRequirement;
      } catch (e) {
        // 保留默认值
      }
    }
    this.semPlans = this.loadList<SemesterPlan>(STORE_KEYS.semPlans);
    this.tasks = this.loadList<TaskCard>(STORE_KEYS.tasks);
    this.candidates = this.loadList<CandidateCourse>(STORE_KEYS.candidates);
    this.comparePlans = this.loadList<ComparePlan>(STORE_KEYS.comparePlans);
    this.study = this.loadList<StudyRecord>(STORE_KEYS.study);
    this.majors = this.loadList<Major>(STORE_KEYS.majors);
    this.archive = this.loadList<ArchiveItem>(STORE_KEYS.archive);
    this.weeklyGoals = this.loadList<WeeklyGoal>(STORE_KEYS.weeklyGoals);
    this.online = this.loadList<OnlineCourse>(STORE_KEYS.online);
    this.mentor = this.loadList<MentorItem>(STORE_KEYS.mentor);
  }

  // ===== 001 课程表 =====
  addCourse(c: CourseInput): void {
    const item: Course = {
      id: genId(),
      name: c.name,
      teacher: c.teacher,
      location: c.location,
      day: c.day,
      start: c.start,
      end: c.end,
      color: c.color,
      credit: c.credit,
      semester: c.semester
    };
    this.courses.push(item);
    this.saveAll();
  }

  updateCourse(c: Course): void {
    const idx = this.courses.findIndex((x) => x.id === c.id);
    if (idx >= 0) {
      this.courses[idx] = c;
      this.saveAll();
    }
  }

  deleteCourse(id: string): void {
    this.courses = this.courses.filter((x) => x.id !== id);
    this.saveAll();
  }

  addTodo(t: TodoInput): void {
    const item: Todo = {
      id: genId(),
      title: t.title,
      done: t.done,
      due: t.due,
      course: t.course
    };
    this.todos.push(item);
    this.saveAll();
  }

  toggleTodo(id: string): void {
    const t = this.todos.find((x) => x.id === id);
    if (t) {
      t.done = !t.done;
      this.saveAll();
    }
  }

  deleteTodo(id: string): void {
    this.todos = this.todos.filter((x) => x.id !== id);
    this.saveAll();
  }

  // ===== 002 学分与毕业 =====
  addTaken(t: TakenInput): void {
    const item: TakenCourse = {
      id: genId(),
      name: t.name,
      credit: t.credit,
      semesterTaken: t.semesterTaken,
      prereq: t.prereq
    };
    this.taken.push(item);
    this.saveAll();
  }

  deleteTaken(id: string): void {
    this.taken = this.taken.filter((x) => x.id !== id);
    this.saveAll();
  }

  setGrad(g: GradRequirement): void {
    this.grad = g;
    this.saveAll();
  }

  setGradFields(totalCredits: number, major: string, categoryCredits: CategoryCredit[]): void {
    this.grad = {
      totalCredits: totalCredits,
      major: major,
      categoryCredits: categoryCredits
    };
    this.saveAll();
  }

  addSemPlan(p: SemesterPlan): void {
    const item: SemesterPlan = { id: p.id === '' ? genId() : p.id, name: p.name, courses: p.courses };
    this.semPlans.push(item);
    this.saveAll();
  }

  deleteSemPlan(id: string): void {
    this.semPlans = this.semPlans.filter((x) => x.id !== id);
    this.saveAll();
  }

  addPlanCourse(planId: string, pc: PlanCourse): void {
    const p = this.semPlans.find((x) => x.id === planId);
    if (p) {
      p.courses.push(pc);
      this.saveAll();
    }
  }

  removePlanCourse(planId: string, index: number): void {
    const p = this.semPlans.find((x) => x.id === planId);
    if (p && index >= 0 && index < p.courses.length) {
      p.courses.splice(index, 1);
      this.saveAll();
    }
  }

  // ===== 003 任务看板 =====
  addTask(t: TaskInput): void {
    const item: TaskCard = {
      id: genId(),
      title: t.title,
      course: t.course,
      deadline: t.deadline,
      status: t.status,
      priority: t.priority
    };
    this.tasks.push(item);
    this.saveAll();
  }

  updateTask(t: TaskCard): void {
    const idx = this.tasks.findIndex((x) => x.id === t.id);
    if (idx >= 0) {
      this.tasks[idx] = t;
      this.saveAll();
    }
  }

  deleteTask(id: string): void {
    this.tasks = this.tasks.filter((x) => x.id !== id);
    this.saveAll();
  }

  setTaskStatus(id: string, status: TaskStatus): void {
    const t = this.tasks.find((x) => x.id === id);
    if (t) {
      t.status = status;
      this.saveAll();
    }
  }

  // ===== 004 选课对比 =====
  addCandidate(c: CandidateInput): void {
    const item: CandidateCourse = {
      id: genId(),
      name: c.name,
      time: c.time,
      credit: c.credit,
      tags: c.tags
    };
    this.candidates.push(item);
    this.saveAll();
  }

  deleteCandidate(id: string): void {
    this.candidates = this.candidates.filter((x) => x.id !== id);
    this.comparePlans.forEach((p) => {
      p.courseIds = p.courseIds.filter((cid) => cid !== id);
    });
    this.saveAll();
  }

  addComparePlan(p: ComparePlan): void {
    const item: ComparePlan = { id: p.id === '' ? genId() : p.id, name: p.name, courseIds: p.courseIds };
    this.comparePlans.push(item);
    this.saveAll();
  }

  deleteComparePlan(id: string): void {
    this.comparePlans = this.comparePlans.filter((x) => x.id !== id);
    this.saveAll();
  }

  togglePlanCourse(planId: string, courseId: string): void {
    const p = this.comparePlans.find((x) => x.id === planId);
    if (!p) {
      return;
    }
    const idx = p.courseIds.indexOf(courseId);
    if (idx >= 0) {
      p.courseIds.splice(idx, 1);
    } else {
      p.courseIds.push(courseId);
    }
    this.saveAll();
  }

  setPlanCourses(planId: string, ids: string[]): void {
    const p = this.comparePlans.find((x) => x.id === planId);
    if (!p) {
      return;
    }
    p.courseIds = ids.slice();
    this.saveAll();
  }

  // ===== 005 学习时间 =====
  addStudy(s: StudyInput): void {
    const item: StudyRecord = {
      id: genId(),
      subject: s.subject,
      minutes: s.minutes,
      date: s.date,
      note: s.note
    };
    this.study.push(item);
    this.saveAll();
  }

  deleteStudy(id: string): void {
    this.study = this.study.filter((x) => x.id !== id);
    this.saveAll();
  }

  // ===== 006 双专业 =====
  addMajor(m: MajorInput): void {
    const item: Major = {
      id: genId(),
      name: m.name,
      requiredCourses: m.requiredCourses
    };
    this.majors.push(item);
    this.saveAll();
  }

  deleteMajor(id: string): void {
    this.majors = this.majors.filter((x) => x.id !== id);
    this.saveAll();
  }

  updateMajor(m: Major): void {
    const idx = this.majors.findIndex((x) => x.id === m.id);
    if (idx >= 0) {
      this.majors[idx] = m;
      this.saveAll();
    }
  }

  // ===== 007 资料归档 =====
  addArchive(a: ArchiveInput): void {
    const item: ArchiveItem = {
      id: genId(),
      name: a.name,
      semester: a.semester,
      course: a.course,
      category: a.category,
      note: a.note
    };
    this.archive.push(item);
    this.saveAll();
  }

  updateArchive(a: ArchiveItem): void {
    const idx = this.archive.findIndex((x) => x.id === a.id);
    if (idx >= 0) {
      this.archive[idx] = a;
      this.saveAll();
    }
  }

  deleteArchive(id: string): void {
    this.archive = this.archive.filter((x) => x.id !== id);
    this.saveAll();
  }

  // ===== 008 周复盘 =====
  addWeeklyGoal(g: WeeklyGoalInput): void {
    const item: WeeklyGoal = {
      id: genId(),
      semester: g.semester,
      goal: g.goal,
      actions: g.actions
    };
    this.weeklyGoals.push(item);
    this.saveAll();
  }

  updateWeeklyGoal(g: WeeklyGoal): void {
    const idx = this.weeklyGoals.findIndex((x) => x.id === g.id);
    if (idx >= 0) {
      this.weeklyGoals[idx] = g;
      this.saveAll();
    }
  }

  deleteWeeklyGoal(id: string): void {
    this.weeklyGoals = this.weeklyGoals.filter((x) => x.id !== id);
    this.saveAll();
  }

  // ===== 009 线上课程 =====
  addOnline(o: OnlineInput): void {
    const item: OnlineCourse = {
      id: genId(),
      platform: o.platform,
      name: o.name,
      totalChapters: o.totalChapters,
      completedChapters: o.completedChapters,
      note: o.note
    };
    this.online.push(item);
    this.saveAll();
  }

  updateOnline(o: OnlineCourse): void {
    const idx = this.online.findIndex((x) => x.id === o.id);
    if (idx >= 0) {
      this.online[idx] = o;
      this.saveAll();
    }
  }

  deleteOnline(id: string): void {
    this.online = this.online.filter((x) => x.id !== id);
    this.saveAll();
  }

  // ===== 010 导师会谈 =====
  addMentor(m: MentorInput): void {
    const item: MentorItem = {
      id: genId(),
      type: m.type,
      content: m.content,
      done: m.done
    };
    this.mentor.push(item);
    this.saveAll();
  }

  toggleMentor(id: string): void {
    const m = this.mentor.find((x) => x.id === id);
    if (m) {
      m.done = !m.done;
      this.saveAll();
    }
  }

  deleteMentor(id: string): void {
    this.mentor = this.mentor.filter((x) => x.id !== id);
    this.saveAll();
  }

  // ===== 重置全部 =====
  resetAll(): void {
    this.courses = [];
    this.todos = [];
    this.taken = [];
    this.grad = { totalCredits: 150, major: '软件工程', categoryCredits: [] };
    this.semPlans = [];
    this.tasks = [];
    this.candidates = [];
    this.comparePlans = [];
    this.study = [];
    this.majors = [];
    this.archive = [];
    this.weeklyGoals = [];
    this.online = [];
    this.mentor = [];
    const cats: CategoryCredit[] = [];
    this.grad = { totalCredits: 150, major: '软件工程', categoryCredits: cats };
    this.saveAll();
  }

  // ===== 示例数据（首次启动） =====
  private seed(): void {
    const today = todayStr();
    this.courses = [
      { id: genId(), name: '高等数学', teacher: '张教授', location: '教三-201', day: 1, start: '08:00', end: '09:40', color: COURSE_COLORS[0], credit: 4, semester: '2026-S1' },
      { id: genId(), name: '数据结构', teacher: '李教授', location: '教二-305', day: 2, start: '10:00', end: '11:40', color: COURSE_COLORS[1], credit: 3, semester: '2026-S1' },
      { id: genId(), name: '英语', teacher: '王老师', location: '外语楼-102', day: 3, start: '14:00', end: '15:40', color: COURSE_COLORS[2], credit: 2, semester: '2026-S1' },
      { id: genId(), name: '操作系统', teacher: '赵教授', location: '教二-210', day: 4, start: '08:00', end: '09:40', color: COURSE_COLORS[3], credit: 3, semester: '2026-S1' }
    ];
    this.todos = [
      { id: genId(), title: '完成高数第三章作业', done: false, due: today, course: '高等数学' },
      { id: genId(), title: '预习数据结构树章节', done: true, due: today, course: '数据结构' }
    ];
    this.taken = [
      { id: genId(), name: '程序设计基础', credit: 4, semesterTaken: '2025-S1', prereq: [] },
      { id: genId(), name: '离散数学', credit: 3, semesterTaken: '2025-S2', prereq: [] },
      { id: genId(), name: '线性代数', credit: 3, semesterTaken: '2025-S2', prereq: [] }
    ];
    const grad: GradRequirement = {
      totalCredits: 150,
      major: '软件工程',
      categoryCredits: [
        { category: '通识必修', credits: 40 },
        { category: '专业核心', credits: 70 },
        { category: '专业选修', credits: 30 },
        { category: '实践环节', credits: 10 }
      ]
    };
    this.grad = grad;
    this.tasks = [
      { id: genId(), title: '提交实验报告', course: '操作系统', deadline: today, status: 'todo', priority: 2 },
      { id: genId(), title: '复习期中考试', course: '数据结构', deadline: today, status: 'doing', priority: 3 },
      { id: genId(), title: '完成英语作文', course: '英语', deadline: today, status: 'done', priority: 1 }
    ];
    this.candidates = [
      { id: genId(), name: '编译原理', time: '周一 3-4节', credit: 3, tags: ['核心', '兴趣'] },
      { id: genId(), name: '计算机网络', time: '周二 1-2节', credit: 3, tags: ['核心'] },
      { id: genId(), name: '人工智能导论', time: '周三 5-6节', credit: 2, tags: ['兴趣', '轻松'] },
      { id: genId(), name: '软件工程', time: '周四 3-4节', credit: 3, tags: ['核心', '实用'] }
    ];
    this.comparePlans = [
      { id: genId(), name: '方案A 偏核心', courseIds: [] },
      { id: genId(), name: '方案B 偏兴趣', courseIds: [] }
    ];
    this.study = [
      { id: genId(), subject: '高等数学', minutes: 120, date: today, note: '第三章习题' },
      { id: genId(), subject: '数据结构', minutes: 90, date: today, note: '树与图' },
      { id: genId(), subject: '英语', minutes: 45, date: today, note: '听力' }
    ];
    this.majors = [
      {
        id: genId(), name: '软件工程', requiredCourses: [
          { name: '程序设计基础', credit: 4, prereq: [] },
          { name: '数据结构', credit: 3, prereq: ['程序设计基础'] },
          { name: '操作系统', credit: 3, prereq: ['数据结构'] },
          { name: '软件工程', credit: 3, prereq: ['数据结构'] }
        ]
      },
      {
        id: genId(), name: '数学与应用数学', requiredCourses: [
          { name: '数学分析', credit: 5, prereq: [] },
          { name: '高等代数', credit: 4, prereq: [] },
          { name: '概率论', credit: 3, prereq: ['高等代数'] }
        ]
      }
    ];
    this.archive = [
      { id: genId(), name: '高数第3章PPT', semester: '2026-S1', course: '高等数学', category: '课件', note: '' },
      { id: genId(), name: '数据结构作业1', semester: '2026-S1', course: '数据结构', category: '作业', note: '二叉树' }
    ];
    this.weeklyGoals = [
      {
        id: genId(), semester: '2026-S1', goal: '本学期绩点达到 3.8', actions: [
          { id: genId(), week: '第1周', action: '制定每日学习计划', done: true, reason: '按计划执行' },
          { id: genId(), week: '第2周', action: '完成高数前两章复习', done: false, reason: '' },
          { id: genId(), week: '第3周', action: '参加英语口语角两次', done: false, reason: '' }
        ]
      }
    ];
    this.online = [
      { id: genId(), platform: '中国大学MOOC', name: 'Python程序设计', totalChapters: 12, completedChapters: 8, note: '' },
      { id: genId(), platform: 'Coursera', name: 'Machine Learning', totalChapters: 10, completedChapters: 3, note: '英文课程' },
      { id: genId(), platform: 'B站', name: '操作系统原理', totalChapters: 20, completedChapters: 15, note: '' }
    ];
    this.mentor = [
      { id: genId(), type: 'question', content: '如何平衡科研与课业？', done: false },
      { id: genId(), type: 'achievement', content: '完成了操作系统实验', done: false },
      { id: genId(), type: 'plan', content: '下学期选修编译原理', done: false }
    ];
    this.saveAll();
  }
}

export default DataStore.getInstance();
