@Entry
@Component
struct Index {
  @State message: string = 'Hello World111'

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontColor($r('app.color.primary'))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}