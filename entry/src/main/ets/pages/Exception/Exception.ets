import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { exceptionReport } from '../../api'
import { HmCard, HmCardItem, HmNavBar, HmSelectCard, HmUpload, HmUploadClass } from '../../components'
import { HmDateTimePicker } from '../../components/HmDateTimePicker'
import { CommonRouterParams, ExceptionParamsType, ExceptionParamsTypeModel } from '../../models'

class ExceptionItemClass {
  name: string = ""
  index: number = 0
}

@Entry
@Component
struct ExceptionReport {

  maxNumber: number = 50

  @State
  @Watch('updateExceptionImagesList')
  exceptionImagesList: HmUploadClass = new HmUploadClass()

  updateExceptionImagesList() {
    this.exceptionForm.exceptionImagesList = this.exceptionImagesList.images
  }


  @State
  selectIndex: number = 0


  @State
  exceptErrorList: string[] = ["发动机启动困难", "不着车、漏油", "照明失灵", "有异常响动", "排烟异常、温度异常", "其他问题"]

  // 异常类型弹层
  typeDialog: CustomDialogController = new CustomDialogController({
    builder: HmSelectCard({ cardContent: () => {
      this.getCardContent()
    }, confirm: () => {
      this.exceptionForm.exceptionType = this.exceptErrorList[this.selectIndex]
      this.typeDialog.close()
    }
    }),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  getBtnEnable () {
    return !!(this.exceptionForm.exceptionDescribe &&
    this.exceptionForm.exceptionPlace &&
    this.exceptionForm.exceptionTime &&
    this.exceptionForm.exceptionType &&
    this.exceptionForm.exceptionDescribe)
  }

  // 单个的渲染选项
  @Builder
  getSingleItem(item: ExceptionItemClass) {
    Row() {
      Text(item.name).fontSize(14).fontWeight(400).fontColor($r('app.color.text_primary'))
      Row() {
        Image(this.selectIndex === item.index ? $r("app.media.ic_check_true") : $r("app.media.ic_check_false")).width(32).height(32)
      }
      .onClick(() => {
        this.selectIndex = item.index
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .border({
      width: {
        bottom:  item.index === this.exceptErrorList.length - 1 ? 0 : 1
      },
      color: $r('app.color.background_divider')
    })
    .width('100%')
    .height(60)
  }
  @Builder
  getCardContent () {
    ForEach(this.exceptErrorList, (name: string, index: number) => {
      this.getSingleItem({ name, index } as ExceptionItemClass)
    })
  }

  @State
  exceptionForm: ExceptionParamsTypeModel = new ExceptionParamsTypeModel({} as ExceptionParamsType)

  dateTimePicker: CustomDialogController = new CustomDialogController({
    builder: HmDateTimePicker({
      onFinish: (value) => {
        this.exceptionForm.exceptionTime = value // 赋值时间
      }
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    autoCancel: false
  })

  onPageShow() {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.exceptionForm.transportTaskId = params.id
    }
    if(params && params.address) {
      this.exceptionForm.exceptionPlace = params.address
    }
  }

  async btnReport () {
    await exceptionReport(this.exceptionForm as ExceptionParamsType)
    promptAction.showToast({
      message: '上报异常成功',
      duration: 3000
    })
    router.back({
      url: 'pages/TaskDetail/TaskDetail',
      params: {
        addExcept: true
      }
    })
  }


  build() {
    Column() {
      HmNavBar({ title: '上报异常' })
      HmCard() {
        HmCardItem({ leftTitle: '异常时间', rightText: this.exceptionForm.exceptionTime || '请选择',
          showRightIcon: false, showBottomBorder: false,
          onRightClick: () => {
            this.dateTimePicker.open()
          }
        })
        HmCardItem({
          leftTitle: '上报位置',
          rightText: this.exceptionForm.exceptionPlace || '请选择',
          onRightClick: () => {
            router.pushUrl({
              url: 'pages/SelectLocation/SelectLocation'
            })
        }})
        HmCardItem({
          leftTitle: '异常类型',
          rightText: this.exceptionForm.exceptionType || '请选择',
          showBottomBorder: false,
          onRightClick: () => {
            this.typeDialog.open()
          }
        })
        HmCardItem({ leftTitle: '异常描述', rightText: '', showRightIcon: false, showBottomBorder: false })

        TextArea({
          placeholder: '请输入异常描述',
          text: this.exceptionForm.exceptionDescribe!
        }).height(130).borderRadius(8).placeholderColor($r('app.color.text_secondary')).fontSize(14).onChange((value) => {
          if(value.length <= this.maxNumber) {
            this.exceptionForm.exceptionDescribe = value
          }
        })
        Text(`${this.exceptionForm.exceptionDescribe?.length || 0}/${this.maxNumber}`)
          .margin({
            top: -30
          })
          .textAlign(TextAlign.End)
          .width('100%')
          .padding({ right: 15 })
          .fontColor($r('app.color.text_secondary'))
        Row().height(20)

      }
      HmCard() {
        HmUpload({ title: '上传图片(最多6张)',  upClass: this.exceptionImagesList, canUpload: true  })
        Row().height(20)
      }
      Row() {
        Button("提交").height(50).width(207).backgroundColor(
          this.getBtnEnable() ?   $r('app.color.primary') :
          $r('app.color.primary_disabled')).
        enabled(this.getBtnEnable())
          .onClick(()=>{
            this.btnReport()
          })
      }.position({
        y: '100%'
      }).height(70).translate({
        y: -70
      }).width('100%').justifyContent(FlexAlign.Center).backgroundColor($r('app.color.white'))
    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}