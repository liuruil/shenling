
import { TOKEN_KEY } from '../../constants'
import { UserSettingClass } from '../../utils/setting'
PersistentStorage.PersistProp(TOKEN_KEY, "")

@Entry
@Component
struct Login {
  @State message: string = '的部分公路也'

  userSetting

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(()=>{
            AppStorage.Set(TOKEN_KEY,'2333')
            new UserSettingClass(getContext()).setUserToken('2333')
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}