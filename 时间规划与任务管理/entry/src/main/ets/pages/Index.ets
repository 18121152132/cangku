// 首页：学习规划与课程管理 - 10 个模块入口
import { router } from '@kit.ArkUI';
import { THEME } from '../components/Common';

interface ModuleInfo {
  code: string;
  title: string;
  desc: string;
  page: string;
  icon: string;
  color: string;
}

const MODULES: ModuleInfo[] = [
  { code: '001', title: '学期课表与冲突检测', desc: '导入/录入课程，自动标记时间冲突', page: 'pages/SchedulePage', icon: '🗓️', color: '#FF6B6B' },
  { code: '002', title: '学分与毕业进度规划', desc: '维护学分与先修，模拟修读方案', page: 'pages/CreditPlanPage', icon: '🎓', color: '#4ECDC4' },
  { code: '003', title: '课程任务与截止日看板', desc: '汇总作业测验，拖拽安排检查冲突', page: 'pages/TaskBoardPage', icon: '📌', color: '#FFD166' },
  { code: '004', title: '选课方案对比器', desc: '并排对比多套方案取舍', page: 'pages/ComparePage', icon: '⚖️', color: '#6A8EFF' },
  { code: '005', title: '个人学习时间统计', desc: '桌面计时器与统计图', page: 'pages/StudyTimePage', icon: '⏱️', color: '#A78BFA' },
  { code: '006', title: '双专业修读路径规划', desc: '整合两专业课程与重叠学分', page: 'pages/DualMajorPage', icon: '🧭', color: '#FF9F68' },
  { code: '007', title: '课程资料文件归档', desc: '按学期课程整理课件作业', page: 'pages/ArchivePage', icon: '🗂️', color: '#2EC4B6' },
  { code: '008', title: '学习目标周复盘', desc: '目标拆周行动，生成复盘报告', page: 'pages/WeeklyReviewPage', icon: '🔄', color: '#E0719B' },
  { code: '009', title: '线上课程学习进度台', desc: '多平台课程统一规划', page: 'pages/OnlineCoursePage', icon: '🌐', color: '#5C80BC' },
  { code: '010', title: '个人导师会谈准备台', desc: '整理议题，生成会谈清单', page: 'pages/MentorPrepPage', icon: '🤝', color: '#7BD389' }
];

@Entry
@Component
struct Index {
  @State greeting: string = '';

  aboutToAppear(): void {
    const h = new Date().getHours();
    if (h < 6) {
      this.greeting = '夜深了，注意休息';
    } else if (h < 12) {
      this.greeting = '上午好，开启高效学习';
    } else if (h < 18) {
      this.greeting = '下午好，保持节奏';
    } else {
      this.greeting = '晚上好，记得复盘';
    }
  }

  build() {
    Column() {
      // 顶部欢迎区
      Column() {
        Text('学习规划与课程管理')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME.text)
        Text(this.greeting)
          .fontSize(14)
          .fontColor(THEME.subText)
          .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ left: 24, right: 24, top: 28, bottom: 12 })

      // 模块网格
      Grid() {
        ForEach(MODULES, (m: ModuleInfo) => {
          GridItem() {
            this.ModuleCard(m)
          }
        }, (m: ModuleInfo) => m.code)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(16)
      .columnsGap(16)
      .padding({ left: 24, right: 24, bottom: 24 })
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME.bg)
  }

  @Builder
  ModuleCard(m: ModuleInfo) {
    Row() {
      Column() {
        Text(m.icon)
          .fontSize(34)
          .width(56)
          .height(56)
          .textAlign(TextAlign.Center)
          .backgroundColor(m.color + '18')
          .borderRadius(14)
      }
      .margin({ right: 14 })

      Column() {
        Row() {
          Text(m.code)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor(m.color)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(8)
          Text(m.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME.text)
            .margin({ left: 8 })
        }
        Text(m.desc)
          .fontSize(12)
          .fontColor(THEME.subText)
          .margin({ top: 8 })
          .maxLines(2)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(THEME.card)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#0000000D', offsetY: 3 })
    .onClick(() => {
      try {
        router.pushUrl({ url: m.page });
      } catch (e) {
        // 忽略
      }
    })
  }
}
