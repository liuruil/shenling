import { HmNavBar, HmCard, HmCardItem } from '../../components'
import geoLocationManager from '@ohos.geoLocationManager';
import webview from '@ohos.web.webview';
import { WebSdkClass } from '../../utils';
import { AddressItem } from '../../models';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SelectLocatn {

  webSdk: WebSdkClass = new WebSdkClass()

  @State
  list: AddressItem[] = []

  aboutToAppear() {
    WebSdkClass.Controller = new webview.WebviewController()
    WebSdkClass.Context = getContext(this)
    WebSdkClass.Context.eventHub.on('search_list', (json: string) => {
      this.list = JSON.parse(json) as AddressItem[]
    })
  }

  aboutToDisappear() {
    // 释放资源
    WebSdkClass.Context.eventHub.off("search_list")
    WebSdkClass.Controller = null
    WebSdkClass.Context = null
  }

  build() {
    Column() {
      HmNavBar({ title: '当前位置' })
      //  地图区域
      Web({ src: $rawfile('location.html'), controller: WebSdkClass.Controller! })
        .height('100%')
        .javaScriptProxy({
          object: this.webSdk,
          name: "shenling",
          methodList: ["toast", "alert", 'getLocation','receiveData'],
          controller: WebSdkClass.Controller!,
        })
        // .onPageEnd(() => {
        //   this.createPorts()
        // })
      Column() {
        HmCard() {
          ForEach(this.list, (item: AddressItem) => {
            HmCardItem({
              leftTitle: item.address,
              rightText: item.distance ? `${item.distance}米` : ''
            })
              .onClick(() => {
                promptAction.showToast({message:'11'})
                router.back({
                  url: "pages/Exception/Exception",
                  params: {
                    address: item.address.substring(0, 7)
                  }
                })
              })
          })
        }
      }.position({
        y: '100%'
      }).translate({
        y: -260
      })

    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}