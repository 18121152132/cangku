// 学习规划与课程管理 - 全局数据模型
// 所有模块均为本地（本地持久化）数据，不涉及云端。

/** 星期 1-7 表示周一至周日 */
export type WeekDay = 1 | 2 | 3 | 4 | 5 | 6 | 7;

/** 课程颜色主题 */
export const COURSE_COLORS: string[] = [
  '#FF6B6B', '#4ECDC4', '#FFD166', '#6A8EFF', '#A78BFA',
  '#FF9F68', '#2EC4B6', '#E0719B', '#7BD389', '#5C80BC'
];

/** 001 学期课表 - 课程 */
export interface Course {
  id: string;
  name: string;
  teacher: string;
  location: string;
  day: WeekDay;        // 1-7
  start: string;       // "HH:mm"
  end: string;         // "HH:mm"
  color: string;       // hex
  credit: number;
  semester: string;    // 例如 "2026-S1"
}

/** 001 学期课表 - 课程输入（无 id） */
export interface CourseInput {
  name: string;
  teacher: string;
  location: string;
  day: WeekDay;
  start: string;
  end: string;
  color: string;
  credit: number;
  semester: string;
}

/** 001 学期课表 - 待办（分屏显示） */
export interface Todo {
  id: string;
  title: string;
  done: boolean;
  due: string;         // "YYYY-MM-DD"
  course: string;
}

/** 001 学期课表 - 待办输入（无 id） */
export interface TodoInput {
  title: string;
  done: boolean;
  due: string;
  course: string;
}

/** 002 学分与毕业进度 - 已修课程 */
export interface TakenCourse {
  id: string;
  name: string;
  credit: number;
  semesterTaken: string;   // 例如 "2025-S2"
  prereq: string[];        // 先修课程名称
}

/** 002 学分与毕业进度 - 已修课程输入（无 id） */
export interface TakenInput {
  name: string;
  credit: number;
  semesterTaken: string;
  prereq: string[];
}

/** 002 毕业要求 - 分类学分 */
export interface CategoryCredit {
  category: string;
  credits: number;
}

/** 002 毕业要求 */
export interface GradRequirement {
  totalCredits: number;
  major: string;
  categoryCredits: CategoryCredit[];
}

/** 002 学期修读模拟方案中的课程 */
export interface PlanCourse {
  name: string;
  credit: number;
  prereq: string[];
}

/** 002 学期修读模拟方案 */
export interface SemesterPlan {
  id: string;
  name: string;             // 例如 "大二上"
  courses: PlanCourse[];
}

/** 003 课程任务看板 - 任务状态 */
export type TaskStatus = 'todo' | 'doing' | 'done';

/** 003 课程任务看板 - 任务卡片 */
export interface TaskCard {
  id: string;
  title: string;
  course: string;
  deadline: string;     // "YYYY-MM-DD"
  status: TaskStatus;
  priority: number;     // 1-3
}

/** 003 课程任务看板 - 任务输入（无 id） */
export interface TaskInput {
  title: string;
  course: string;
  deadline: string;
  status: TaskStatus;
  priority: number;
}

/** 004 选课方案对比器 - 候选课程 */
export interface CandidateCourse {
  id: string;
  name: string;
  time: string;         // 例如 "周一 3-4节"
  credit: number;
  tags: string[];       // 个人偏好标签，例如 ["兴趣","核心"]
}

/** 004 选课方案对比器 - 候选课程输入（无 id） */
export interface CandidateInput {
  name: string;
  time: string;
  credit: number;
  tags: string[];
}

/** 004 选课方案对比器 - 对比方案 */
export interface ComparePlan {
  id: string;
  name: string;
  courseIds: string[];
}

/** 005 个人学习时间统计 - 学习记录 */
export interface StudyRecord {
  id: string;
  subject: string;
  minutes: number;
  date: string;         // YYYY-MM-DD
  note: string;
}

/** 005 个人学习时间统计 - 学习记录输入（无 id） */
export interface StudyInput {
  subject: string;
  minutes: number;
  date: string;
  note: string;
}

/** 006 双专业 - 单门专业课程 */
export interface MajorCourse {
  name: string;
  credit: number;
  prereq: string[];
}

/** 006 双专业 - 专业 */
export interface Major {
  id: string;
  name: string;
  requiredCourses: MajorCourse[];
}

/** 006 双专业 - 专业输入（无 id） */
export interface MajorInput {
  name: string;
  requiredCourses: MajorCourse[];
}

/** 007 课程资料文件归档 */
export interface ArchiveItem {
  id: string;
  name: string;
  semester: string;
  course: string;
  category: string;     // 课件 / 作业 / 参考资料
  note: string;
}

/** 007 课程资料文件归档 - 输入（无 id） */
export interface ArchiveInput {
  name: string;
  semester: string;
  course: string;
  category: string;
  note: string;
}

/** 008 学习目标周复盘 - 周行动 */
export interface WeeklyAction {
  id: string;
  week: string;         // 例如 "第3周"
  action: string;
  done: boolean;
  reason: string;       // 完成/未完成原因
}

/** 008 学习目标周复盘 */
export interface WeeklyGoal {
  id: string;
  semester: string;
  goal: string;
  actions: WeeklyAction[];
}

/** 008 学习目标周复盘 - 输入（无 id） */
export interface WeeklyGoalInput {
  semester: string;
  goal: string;
  actions: WeeklyAction[];
}

/** 009 线上课程学习进度台 */
export interface OnlineCourse {
  id: string;
  platform: string;
  name: string;
  totalChapters: number;
  completedChapters: number;
  note: string;
}

/** 009 线上课程学习进度台 - 输入（无 id） */
export interface OnlineInput {
  platform: string;
  name: string;
  totalChapters: number;
  completedChapters: number;
  note: string;
}

/** 010 个人导师会谈准备台 - 条目类型 */
export type MentorType = 'question' | 'achievement' | 'plan';

/** 010 个人导师会谈准备台 */
export interface MentorItem {
  id: string;
  type: MentorType;
  content: string;
  done: boolean;
}

/** 010 个人导师会谈准备台 - 输入（无 id） */
export interface MentorInput {
  type: MentorType;
  content: string;
  done: boolean;
}

/** 007 归档分类定义 */
export interface CategoryDef {
  key: string;
  color: string;
}

/** 010 导师条目类型定义 */
export interface MentorTypeDef {
  key: MentorType;
  label: string;
  color: string;
}

/** 004 方案匹配结果 */
export interface MatchResult {
  matched: number;
  total: number;
}

/** 005 学科汇总 */
export interface SubjectTotal {
  subject: string;
  minutes: number;
}

/** 008 完成度 */
export interface Completion {
  done: number;
  total: number;
}

/** 006 合并课程（含所属专业） */
export interface CombinedCourse {
  name: string;
  credit: number;
  prereq: string[];
  majors: string[];
}

/** 统一存储键 */
export interface StoreKeys {
  courses: string;
  todos: string;
  taken: string;
  grad: string;
  semPlans: string;
  tasks: string;
  candidates: string;
  comparePlans: string;
  study: string;
  majors: string;
  archive: string;
  weeklyGoals: string;
  online: string;
  mentor: string;
  seeded: string;
}

export const STORE_KEYS: StoreKeys = {
  courses: 'courses',
  todos: 'todos',
  taken: 'taken',
  grad: 'grad',
  semPlans: 'semPlans',
  tasks: 'tasks',
  candidates: 'candidates',
  comparePlans: 'comparePlans',
  study: 'study',
  majors: 'majors',
  archive: 'archive',
  weeklyGoals: 'weeklyGoals',
  online: 'online',
  mentor: 'mentor',
  seeded: 'seeded'
};
