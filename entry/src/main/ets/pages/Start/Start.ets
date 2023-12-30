import router from '@ohos.router'
import { AdvertClass } from '../../models'
import { UserSettingClass } from '../../utils'

@Entry
@Component
struct Start {
  userSetting: UserSettingClass = new UserSettingClass(getContext(this))

  @State
  adObj: AdvertClass  = {
    showAd: false,
    adTime: 0,
    adImg:''
  }
  timer: number = -1
  async aboutToAppear() {
    this.adObj = await this.userSetting.getUserAd()
    this.timer = setInterval(() => {
      if(this.adObj.adTime === 0) {
        clearInterval(this.timer)
        router.replaceUrl({ url: 'pages/Index' })
        return
      }
      this.adObj.adTime--
    }, 1000)
  }

  aboutToDisappear(){
    clearInterval(this.timer)
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      // 启动广告页面
      Image(this.adObj.adImg).objectFit(ImageFit.Cover)
      // 倒计时文本
      Text(`${this.adObj.adTime}秒后跳过`)
        .padding({ left: 10, right: 10 })
        .margin({ right: 20, top: 20 })
        .height(30)
        .fontSize(14)
        .borderRadius(15)
        .backgroundColor($r('app.color.background_page'))
        .textAlign(TextAlign.Center)
        .onClick(()=>{
          clearInterval(this.timer)
          router.replaceUrl({ url: 'pages/Index' })
        })

    }.height('100%').width('100%')
  }
}
