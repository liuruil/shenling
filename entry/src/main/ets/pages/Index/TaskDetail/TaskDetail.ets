// import { HmNavBar } from '../../components'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { getTaskDetail, pickUp } from '../../../api'
import { HmLoading, HmNavBar,HmToggleCard, HmUpload, HmUploadClass } from '../../../components'
// import {  HmToggleCard } from '../../components'
import { CommonRouterParams, PickUpParamsModel, TaskDetailInfo, TaskDetailInfoModel } from '../../../models'

@Extend(Text) function baseTextOneStyle() {
  .fontSize(12)
  .fontColor($r('app.color.white'))
  .backgroundColor($r('app.color.text_primary'))
  .width(22)
  .height(22)
  .borderRadius(11)
  .textAlign(TextAlign.Center)
}

@Extend(Text) function baseTextTwoStyle() {
  .margin({ left: 11.5 }).fontColor($r('app.color.text_secondary')).fontSize(14).lineHeight(20)
}


class BaseBuilderClass {
  title: string = ""
  value: string = ""
  icon?: ResourceStr = ""
}

@Entry
@Component
struct TaskDetail {

  layer: CustomDialogController = new CustomDialogController({
    customStyle: true,
    alignment: DialogAlignment.Center,
    builder: HmLoading({ loadingText: '详情加载中' })
  })

  @State
  taskDetailData: TaskDetailInfoModel = new TaskDetailInfoModel({} as TaskDetailInfo)

  @State
  @Watch('updateCargoPickUp')
  cargoPickUpClass: HmUploadClass = new HmUploadClass() // 提货凭证

  @State
  @Watch('updateCargo')
  cargoClass: HmUploadClass = new HmUploadClass() // 提货图片

  // 监听数据的变化
  updateCargoPickUp () {
    this.taskDetailData.cargoPickUpPictureList = this.cargoPickUpClass.images
  }

  // 获取提货状态
  getPickUpState () {
    return this.taskDetailData.cargoPickUpPictureList?.length > 0 &&
    this.taskDetailData.cargoPictureList?.length > 0
    && this.taskDetailData.cargoPickUpPictureList.every(item => !!item.url)
    && this.taskDetailData.cargoPictureList.every(item => !!item.url)
  }


  // 提货
  async btnPickUp () {
    await pickUp(new PickUpParamsModel({
      id: this.taskDetailData.id,
      cargoPickUpPictureList: this.taskDetailData.cargoPickUpPictureList,
      cargoPictureList: this.taskDetailData.cargoPictureList
    }))
    promptAction.showToast({
      message: '提货成功',
      duration: 3000
    })
    this.getTaskDetail(this.taskDetailData.id) // 重新加载数据
  }

  // 监听数据的变化
  updateCargo() {
    this.taskDetailData.cargoPictureList = this.cargoClass.images
  }

  scroller: Scroller = new Scroller() // 滚动

  aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if(params && params.id) {
      this.getTaskDetail(params.id)
      // AlertDialog.show({
      //   message: params.id
      // })
    }
  }

  async getTaskDetail(id: string) {
    this.layer.open()
    this.taskDetailData = await getTaskDetail(id)
    // 赋值提货数据
    this.cargoPickUpClass.images = this.taskDetailData.cargoPickUpPictureList || []
    this.cargoClass.images = this.taskDetailData.cargoPictureList || []
    this.layer.close()
  }

  @Builder
  getBaseContentItem(item: BaseBuilderClass) {
    Row() {
      Text(item.title).fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Row() {
        Text(item.value).fontSize(14).fontColor($r('app.color.text_secondary'))
        if (item.icon) {
          Image(item.icon).width(24).height(24)
        }
      }
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })
  }

  // 获取基础信息
  @Builder
  getBaseContent() {
    Row() {
      Column() {
        Row() {
          Text("起").baseTextOneStyle()
          Text("北京市昌平区回龙观街道西三旗桥东金燕龙写字楼8877号").baseTextTwoStyle()
        }.margin({ top: 21 })
        Row() {
          Text("止").baseTextOneStyle().backgroundColor($r('app.color.primary'))
          Text("河南省郑州市路北区北清路99号").baseTextTwoStyle()
        }.margin({ top: 14.5 })
      }.alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({
        right: 20
      })

      Column() {
        Image($r("app.media.ic_navigation")).width(22).height(22)
        Text("开始导航").fontSize(14).margin({ top: 10, bottom: 10 })
      }.justifyContent(FlexAlign.SpaceBetween)
      .margin({
        top: 20
      })

    }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%')

    Divider().vertical(false).height(2).color($r('app.color.background_divider')).margin({ left: 8, right: 8, top: 21 })
    this.getBaseContentItem({
      title: '任务编号',
      value:  this.taskDetailData.transportTaskId
    })
    this.getBaseContentItem({
      title: '联系人',
      value: this.taskDetailData.startHandoverName
    })
    this.getBaseContentItem({
      title: '联系电话',
      value: this.taskDetailData.startHandoverPhone,
      icon: $r('app.media.ic_phone')
    })
    this.getBaseContentItem({
      title: '提货时间',
      value: this.taskDetailData.planDepartureTime
    })
    this.getBaseContentItem({
      title: '预计送达时间',
      value: this.taskDetailData.planArrivalTime
    })

  }

  // 司机信息
  @Builder
  getDriverContent() {
    Row() {
      Text(`车牌号`).fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Text(this.taskDetailData.licensePlate).fontSize(14).fontColor($r('app.color.text_secondary'))
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })

    Row() {
      Text(`司机姓名`).fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Text(this.taskDetailData.driverName).fontSize(14).fontColor($r('app.color.text_secondary'))
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })
  }
  // 运输路线
  @Builder
  getTransLineContent() {
    Row() {
      Column() {
        Text(this.taskDetailData.startProvince).fontSize(16).fontColor($r('app.color.text_primary')).lineHeight(22).fontWeight(600)
        Text(this.taskDetailData.startCity).fontSize(14).lineHeight(22)
      }.width(50)

      Image($r("app.media.ic_right_arrow")).width(36).height(16)
      Column() {
        Text(this.taskDetailData.endProvince).fontSize(16).fontColor($r('app.color.text_primary')).lineHeight(22).fontWeight(600)
        Text(this.taskDetailData.endCity).fontSize(14).lineHeight(22)
      }.width(50)
    }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%').padding({
      left: 60,
      right: 60
    })
  }

  // 提货信息内容
  @Builder
  getPickUpContent() {
    HmUpload({ title: '请拍照上传回单凭证',upClass: this.cargoPickUpClass})
    HmUpload({ title: '请拍照上传货品照片',upClass: this.cargoClass })
  }

  // 底部按钮结构
  @Builder
  getBottomBtn() {
    //已完成不显示任何按钮
    Row() {
      Button("延迟收货", { type: ButtonType.Capsule })
        .backgroundColor($r('app.color.btn_gray'))
        .fontColor($r('app.color.text_primary'))
        .fontSize(16)
        .height(50)
        .width(125)
      Button("提货", { type: ButtonType.Capsule })
        .backgroundColor($r('app.color.primary_disabled'))
        .fontColor($r('app.color.white'))
        .height(50)
        .flexGrow(1)
        .margin({ left: 13 })
        .backgroundColor(this.getPickUpState() ? $r('app.color.primary') : $r('app.color.primary_disabled'))
        .enabled(this.getPickUpState())
        .onClick(() => {
          this.btnPickUp()
        })
    }
    .width('100%')
    .padding({ left: 15, right: 15 })
    .height(70).
    justifyContent(FlexAlign.SpaceBetween).
    alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.white'))
    .position({ y: '100%' })
    .translate({ y: -70 })
  }

  build() {
    Column() {
      HmNavBar({ title: '任务详情' })
      Scroll(this.scroller) {
        Column() {
          HmToggleCard({ title: '基本信息' }) {
            this.getBaseContent()
          }
          HmToggleCard({ title: '车辆司机信息' }) {
            this.getDriverContent()
          }
          HmToggleCard({ title: '运输路线' }) {
            this.getTransLineContent()
          }
          HmToggleCard({ title: '提货信息' }) {
            this.getPickUpContent()
          }
        }.padding({
          bottom: 120
        })
        this.getBottomBtn() // 底部按钮结构
      }
    }.backgroundColor($r('app.color.background_page')).
    height('100%')
  }
}