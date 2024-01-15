import webview from '@ohos.web.webview';
import router from '@ohos.router';
import { HmNavBar } from '../../components/HmNavBar'
import { CommonRouterParams } from '../../models';
import { WebSdkClass } from '../../utils';
@Entry
@Component
struct NavigationPage {

  aboutToAppear() {
    WebSdkClass.Controller = new webview.WebviewController()
    WebSdkClass.Context = getContext(this)
  }
  aboutToDisappear() {
    WebSdkClass.Controller = null
    WebSdkClass.Context = null
  }

  build() {
    Column() {
      HmNavBar({ title: '导航' })
      //  地图区域
      Web({ src: $rawfile('navigation_page.html'), controller: WebSdkClass.Controller! }).height('100%')
        .onPageEnd(() => {
          const params = router.getParams() as CommonRouterParams
          if(params && params.start && params.end) {
            WebSdkClass.Controller!.runJavaScript(`beginDriving('${params.start}','${params.end}')`)
          }
      })
    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}