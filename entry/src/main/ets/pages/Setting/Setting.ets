import { HmCardItem } from '../../components/HmCardItem'
import  { HmCard } from '../../components/HmCard'
import { HmConfirm, HmNavBar } from '../../components'
import { TOKEN_KEY } from '../../constants'
import { UserSettingClass } from '../../utils'
import router from '@ohos.router'
@Entry
@Component
struct Setting {
  confirm: CustomDialogController = new CustomDialogController({
    builder: HmConfirm({
      message: '确定要退出登录吗?',
      buttonList: [{
        text: '取消'
      },{
        text: '确定',
        fontColor: $r('app.color.primary'),
        action: () => {
          this.logout()
        }
      }]
    }),
    customStyle: true,
    alignment: DialogAlignment.Center, // 弹出的位置
    autoCancel: false
  })

  logout () {
    // 删除token
    AppStorage.Set<string>(TOKEN_KEY, "")
    new UserSettingClass(getContext(this)).setUserToken("")
    router.replaceUrl({
      url: 'pages/Login/Login'
    })
  }

  build() {
    Column() {
      HmNavBar({ title: '系统设置' })
      HmCard() {
        HmCardItem({
          leftTitle: '换绑手机',
          rightText: '',
          onRightClick: () => {
            router.pushUrl({
              url: 'pages/Setting/BindMobile'
            })
          }
        })
        HmCardItem({
          leftTitle: '修改密码',
          rightText: '',
          onRightClick: () => {
            router.pushUrl({
              url: 'pages/Setting/ChangePassword'
            })
          }
        })
        HmCardItem({
          leftTitle: '消息通知设置',
          rightText: '',
          onRightClick: () => {
            router.pushUrl({
              url: 'pages/Setting/MessageSend'
            })
          }
        })
        HmCardItem({ leftTitle: '清理缓存', rightText: '', showBottomBorder: false })
      }
      Row() {
        Button("退出", { type: ButtonType.Normal })
          .backgroundColor($r('app.color.white'))
          .fontColor($r("app.color.text_primary"))
          .width('100%')
          .borderRadius(8)
          .height(60)
          .onClick(() => {
            this.confirm.open()
          })
      }.width('100%').margin({
        top: 20
      }).padding({
        left: 15,
        right: 15
      })
      .justifyContent(FlexAlign.Center)
    }.width('100%')
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}