import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { TOKEN_KEY } from '../constants';
import { AdvertClass } from '../models';
import { UserSettingClass } from '../utils/setting';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl'
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import promptAction from '@ohos.promptAction';

export default class EntryAbility extends UIAbility {

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void>  {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    let manger = abilityAccessCtrl.createAtManager()
    try {
      await manger.requestPermissionsFromUser(this.context,
        [
          'ohos.permission.MEDIA_LOCATION',
          'ohos.permission.LOCATION',
          'ohos.permission.APPROXIMATELY_LOCATION',
        ])
    } catch (err) {
      promptAction.showToast({ message: '获取位置失败' })
    }
  }


  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // 判断有没有广告
    const userSetting = new UserSettingClass(this.context)

    // 这里要尝试去读一下运营的配置-我们现在还没有实现接口，直接模拟一下
    // const result = await new Promise<AdvertClass>((resolve, reject) => {
    //   setTimeout(() => {
    //     resolve({
    //       showAd: true,
    //       adTime: 10,
    //       adImg: $r("app.media.start")
    //     } as AdvertClass)
    //   }, 500)
    // })
    // await userSetting.setUserAd(result) // 写入首选项

    const adSetting = await userSetting.getUserAd()
    if(adSetting.showAd) {
      // 显示广告
      windowStage.loadContent('pages/Start/Start'); // 跳转广告页
    }else {
      // 通过首选项的方式拿到token
      const token = await userSetting.getUserToken()
      if(token) {
        // 有token
        windowStage.loadContent('pages/Index/Index');
      }else {
        windowStage.loadContent('pages/Login/Login');
      }
    }
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
