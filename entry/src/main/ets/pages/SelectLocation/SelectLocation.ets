import { HmNavBar, HmCard, HmCardItem } from '../../components'
import geoLocationManager from '@ohos.geoLocationManager';
import webview from '@ohos.web.webview';
import { WebSdkClass } from '../../utils';
import { AddressItem } from '../../models';
import router from '@ohos.router';

@Entry
@Component
struct SelectLocatn {

  webSdk: WebSdkClass = new WebSdkClass()

  // messagePorts: webview.WebMessagePort[] = []
  //
  // webController: webview.WebviewController = new webview.WebviewController()
  //
  // // 创建信道
  // createPorts() {
  //   this.messagePorts = this.webController.createWebMessagePorts() // 创建两个端口，一个自己用，一个html页面用
  //   // 监听 html页面发送的消息
  //   this.messagePorts[1].onMessageEvent((msg) => {
  //     if(typeof msg === 'string') {
  //       const data = JSON.parse(msg)
  //       if(data.type === 'connect_ok'){
  //         AlertDialog.show({ message: '双向通信建立成功' })
  //       }
  //     }
  //   })
  //   this.webController.postMessage("__init_port__", [this.messagePorts[0]], "*")
  // }

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
          methodList: ["toast", "alert", 'getLocation'],
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