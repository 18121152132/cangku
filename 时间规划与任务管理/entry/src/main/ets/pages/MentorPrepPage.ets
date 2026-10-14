// 010 个人导师会谈准备台
// 整理学习问题/成果/计划；会谈前快速生成议题清单
import DataStore from '../model/DataStore';
import { MentorItem, MentorType, MentorTypeDef } from '../model/types';
import { BackHeader, EmptyHint, THEME, DialogShell, Field } from '../components/Common';

const TYPES: MentorTypeDef[] = [
  { key: 'question', label: '学习问题', color: '#FF6B6B' },
  { key: 'achievement', label: '近期成果', color: '#2EC4B6' },
  { key: 'plan', label: '下阶段计划', color: '#3A7AFE' }
];

@Entry
@Component
struct MentorPrepPage {
  @State mentor: MentorItem[] = [];
  @State showAdd: boolean = false;
  @State addType: MentorType = 'question';
  @State addContent: string = '';
  @State showAgenda: boolean = false;
  @State agendaText: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.mentor = DataStore.mentor.slice();
  }

  itemsOf(type: MentorType): MentorItem[] {
    return this.mentor.filter((m) => m.type === type);
  }

  buildAgenda(): string {
    let s = '【导师会谈议题清单】\n\n';
    for (const t of TYPES) {
      s += '■ ' + t.label + '\n';
      const list = this.itemsOf(t.key);
      if (list.length === 0) {
        s += '（暂无）\n';
      } else {
        for (const m of list) {
          s += (m.done ? '  [x] ' : '  [ ] ') + m.content + '\n';
        }
      }
      s += '\n';
    }
    s += '———\n会谈时间：____  地点：____\n';
    return s;
  }

  build() {
    Stack() {
      Column() {
        BackHeader({ title: '个人导师会谈准备台', subtitle: '010 · 整理议题并生成清单' })

        Row() {
          Button('生成议题清单')
            .height(34).fontSize(13).backgroundColor(THEME.primary).fontColor('#FFFFFF')
            .onClick(() => {
              this.agendaText = this.buildAgenda();
              this.showAgenda = true;
            })
          Button('+ 添加条目')
            .height(34).fontSize(13).backgroundColor('#EEF1F7').fontColor(THEME.text)
            .margin({ left: 12 })
            .onClick(() => {
              this.addType = 'question'; this.addContent = '';
              this.showAdd = true;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })

        Scroll() {
          Row() {
            ForEach(TYPES, (t: MentorTypeDef) => {
              this.TypeColumn(t)
            }, (t: MentorTypeDef) => t.key)
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

      DialogShell({ visible: this.showAdd, title: '添加条目', onCancel: () => this.showAdd = false, child: this.AddDialogContent })
      DialogShell({ visible: this.showAgenda, title: '议题清单（可编辑）', onCancel: () => this.showAgenda = false, child: this.AgendaDialogContent })
    }
  }

  @Builder
  TypeColumn(t: MentorTypeDef) {
    Column() {
      Row() {
        Text(t.label)
          .fontSize(15).fontWeight(FontWeight.Bold).fontColor(THEME.text)
        Text(String(this.itemsOf(t.key).length))
          .fontSize(12).fontColor('#FFFFFF').backgroundColor(t.color)
          .padding({ left: 8, right: 8, top: 1, bottom: 1 }).borderRadius(8)
          .margin({ left: 8 })
        Blank()
        Text('+')
          .fontSize(16).fontColor(t.color).padding(4)
          .onClick(() => {
            this.addType = t.key; this.addContent = '';
            this.showAdd = true;
          })
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.itemsOf(t.key).length === 0) {
        Text('点击 + 添加')
          .fontSize(12).fontColor(THEME.subText)
          .width('100%').height(60)
          .textAlign(TextAlign.Center)
          .backgroundColor('#F0F2F7').borderRadius(10)
      } else {
        ForEach(this.itemsOf(t.key), (m: MentorItem) => {
          Row() {
            Text(m.done ? '✓' : '○')
              .fontSize(16)
              .fontColor(m.done ? THEME.success : THEME.subText)
              .width(26)
              .onClick(() => { DataStore.toggleMentor(m.id); this.refresh(); })
            Text(m.content)
              .fontSize(13).fontColor(m.done ? THEME.subText : THEME.text)
              .layoutWeight(1)
              .margin({ left: 4 })
              .decoration({ type: m.done ? TextDecorationType.LineThrough : TextDecorationType.None })
            Text('🗑').fontSize(13).fontColor(THEME.subText).padding(4)
              .onClick(() => { DataStore.deleteMentor(m.id); this.refresh(); })
          }
          .width('100%')
          .padding(10)
          .backgroundColor(THEME.card)
          .borderRadius(10)
          .margin({ bottom: 8 })
          .alignItems(VerticalAlign.Center)
        }, (m: MentorItem) => m.id)
      }
    }
    .width('33%')
    .padding(10)
    .backgroundColor('#EEF1F7')
    .borderRadius(14)
    .margin({ right: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AddDialogContent() {
    Column() {
      Text('类型')
        .fontSize(12).fontColor(THEME.subText).alignSelf(ItemAlign.Start)
      Row() {
        ForEach(TYPES, (t: MentorTypeDef) => {
          Text(t.label)
            .fontSize(12)
            .fontColor(this.addType === t.key ? '#FFFFFF' : THEME.subText)
            .backgroundColor(this.addType === t.key ? THEME.primary : '#EEF1F7')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .borderRadius(12)
            .margin({ right: 8, top: 6 })
            .onClick(() => { this.addType = t.key; })
        }, (t: MentorTypeDef) => t.key)
      }
      .width('100%')
      Field('内容', this.addContent, (v) => { this.addContent = v; }, '如：如何平衡科研与课业')
      Row() {
        Button('取消').layoutWeight(1).backgroundColor('#F2F4F8').fontColor(THEME.text)
          .onClick(() => { this.showAdd = false; })
        Button('添加').layoutWeight(1).margin({ left: 12 }).backgroundColor(THEME.primary)
          .onClick(() => {
            if (this.addContent.trim() === '') {
              return;
            }
            DataStore.addMentor({
              type: this.addType,
              content: this.addContent.trim(),
              done: false
            });
            this.showAdd = false;
            this.refresh();
          })
      }
      .margin({ top: 16 }).width('100%')
    }
    .width('100%')
  }

  @Builder
  AgendaDialogContent() {
    Column() {
      TextArea({ text: this.agendaText })
        .onChange((v: string) => { this.agendaText = v; })
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
        .onClick(() => { this.showAgenda = false; })
    }
    .width('100%')
  }
}
