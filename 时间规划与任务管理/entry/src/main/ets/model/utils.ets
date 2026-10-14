// 通用工具函数：冲突检测、时间格式化、ID 生成
import { Course } from './types';

/** 生成唯一 ID */
export function genId(): string {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
}

/** "HH:mm" -> 当日的分钟数 */
export function timeToMinutes(hhmm: string): number {
  const parts = hhmm.split(':');
  if (parts.length < 2) {
    return 0;
  }
  const h = Number(parts[0]);
  const m = Number(parts[1]);
  if (isNaN(h) || isNaN(m)) {
    return 0;
  }
  return h * 60 + m;
}

/** 校验 "HH:mm" 是否合法 */
export function isValidTime(hhmm: string): boolean {
  const parts = hhmm.split(':');
  if (parts.length !== 2) {
    return false;
  }
  const h = Number(parts[0]);
  const m = Number(parts[1]);
  return h >= 0 && h <= 23 && m >= 0 && m <= 59 && !isNaN(h) && !isNaN(m);
}

/** 两门课程是否在同一天且时间重叠 */
export function coursesOverlap(a: Course, b: Course): boolean {
  if (a.day !== b.day) {
    return false;
  }
  const aS = timeToMinutes(a.start);
  const aE = timeToMinutes(a.end);
  const bS = timeToMinutes(b.start);
  const bE = timeToMinutes(b.end);
  if (aE <= aS || bE <= bS) {
    return false;
  }
  return aS < bE && bS < aE;
}

/** 找出所有冲突课程对，返回冲突课程 id 集合 */
export function findConflictIds(courses: Course[]): Set<string> {
  const conflict: Set<string> = new Set<string>();
  for (let i = 0; i < courses.length; i++) {
    for (let j = i + 1; j < courses.length; j++) {
      if (coursesOverlap(courses[i], courses[j])) {
        conflict.add(courses[i].id);
        conflict.add(courses[j].id);
      }
    }
  }
  return conflict;
}

/** 找到与指定课程冲突的其他课程名称列表 */
export function getConflictPartners(target: Course, courses: Course[]): string[] {
  const partners: string[] = [];
  for (const c of courses) {
    if (c.id !== target.id && coursesOverlap(target, c)) {
      partners.push(c.name);
    }
  }
  return partners;
}

/** 分钟数格式化为 "Xh Ym" */
export function formatMinutes(min: number): string {
  if (min <= 0) {
    return '0m';
  }
  const h = Math.floor(min / 60);
  const m = min % 60;
  if (h === 0) {
    return m + 'm';
  }
  if (m === 0) {
    return h + 'h';
  }
  return h + 'h ' + m + 'm';
}

const DAY_NAMES: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

/** 星期数字 -> 中文 */
export function dayToChinese(day: number): string {
  if (day >= 1 && day <= 7) {
    return DAY_NAMES[day - 1];
  }
  return '周一';
}

/** 今日是星期几（1-7），本地时间 */
export function todayDay(): number {
  const jsDay = new Date().getDay(); // 0=周日
  return jsDay === 0 ? 7 : jsDay;
}

/** 今日日期 "YYYY-MM-DD" */
export function todayStr(): string {
  const d = new Date();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return d.getFullYear() + '-' + mm + '-' + dd;
}

/** 距离截止日还有几天（负数表示已逾期） */
export function daysUntil(deadline: string): number {
  const d1 = new Date(deadline).getTime();
  const d2 = new Date(todayStr()).getTime();
  return Math.round((d1 - d2) / 86400000);
}

/** 字符串转数字，失败返回 0 */
export function toNumberSafe(v: string | number): number {
  const n = Number(v);
  return isNaN(n) ? 0 : n;
}
