// 公共 UI 组件：页面头、空状态、标签、统计卡片、悬浮添加按钮
import { router } from '@kit.ArkUI';

/** 全局配色 */
export interface Theme {
  primary: string;
  bg: string;
  card: string;
  text: string;
  subText: string;
  border: string;
  danger: string;
  success: string;
  warn: string;
}

export const THEME: Theme = {
  primary: '#3A7AFE',
  bg: '#F5F7FB',
  card: '#FFFFFF',
  text: '#1A1A1A',
  subText: '#8A90A2',
  border: '#E8EBF2',
  danger: '#FF5A5F',
  success: '#2EC4B6',
  warn: '#FFB020'
};

/** 页面顶部标题栏（含返回） */
@Component
export struct BackHeader {
  @Prop title: string = '';
  @Prop subtitle: string = '';

  build() {
    Row() {
      Text('‹')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME.primary)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          try {
            router.back();
          } catch (e) {
            // 忽略
          }
        })
      Column() {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME.text)
        if (this.subtitle !== '') {
          Text(this.subtitle)
            .fontSize(13)
            .fontColor(THEME.subText)
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 4 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 12 })
  }
}

/** 空状态提示 */
@Component
export struct EmptyHint {
  @Prop text: string = '暂无数据';

  build() {
    Column() {
      Text('📭')
        .fontSize(40)
        .margin({ bottom: 8 })
      Text(this.text)
        .fontSize(14)
        .fontColor(THEME.subText)
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .alignItems(HorizontalAlign.Center)
  }
}

/** 标签胶囊 */
@Component
export struct TagView {
  @Prop text: string = '';
  @Prop color: string = THEME.primary;

  build() {
    Text(this.text)
      .fontSize(12)
      .fontColor(this.color)
      .backgroundColor(this.color + '1A')
      .padding({ left: 10, right: 10, top: 3, bottom: 3 })
      .borderRadius(12)
  }
}

/** 统计卡片 */
@Component
export struct StatCard {
  @Prop value: string = '';
  @Prop label: string = '';
  @Prop color: string = THEME.primary;

  build() {
    Column() {
      Text(this.value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
      Text(this.label)
        .fontSize(12)
        .fontColor(THEME.subText)
        .margin({ top: 4 })
    }
    .width('30%')
    .padding(14)
    .backgroundColor(THEME.card)
    .borderRadius(14)
    .shadow({ radius: 6, color: '#00000010', offsetY: 2 })
  }
}

/** 右下角悬浮添加按钮 */
@Component
export struct AddButton {
  onAdd: () => void = () => {};

  build() {
    Button('+')
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor(THEME.primary)
      .fontSize(30)
      .fontColor('#FFFFFF')
      .shadow({ radius: 10, color: '#3A7AFE40', offsetY: 4 })
      .onClick(() => {
        this.onAdd();
      })
  }
}

/** 顶部带标题的通用对话框容器（遮罩 + 卡片） */
@Component
export struct DialogShell {
  @Prop visible: boolean = false;
  @Prop title: string = '';
  @BuilderParam child: () => void;
  onCancel: () => void = () => {};

  build() {
    if (this.visible) {
      Stack() {
        Column() { }
          .width('100%')
          .height('100%')
          .backgroundColor('#00000050')
          .onClick(() => { this.onCancel(); })
        Column() {
          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME.text)
            .margin({ bottom: 12 })
          this.child()
        }
        .width('76%')
        .constraintSize({ maxHeight: '92%' })
        .padding(20)
        .backgroundColor(THEME.card)
        .borderRadius(16)
        .shadow({ radius: 16, color: '#00000020', offsetY: 6 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Center)
    }
  }
}

/** 通用单行输入字段（顶层 builder，可跨文件复用） */
@Builder
export function Field(label: string, value: string, onChange: (v: string) => void, placeholder: string) {
  Column() {
    Text(label)
      .fontSize(12)
      .fontColor(THEME.subText)
    TextInput({ placeholder: placeholder, text: value })
      .onChange((v: string) => onChange(v))
      .width('100%')
      .height(40)
      .backgroundColor('#F2F4F8')
      .borderRadius(8)
      .margin({ top: 4 })
  }
  .width('100%')
  .margin({ top: 10 })
  .alignItems(HorizontalAlign.Start)
}
