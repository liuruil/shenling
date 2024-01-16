import promptAction from '@ohos.promptAction'
import { getTaskList } from '../../../api'
import { HmLoading,HmList } from '../../../components'
import TaskItemCard from './TaskItemCard'
import { TaskInfoItemModel, TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models/task'
@Preview
@Component
struct TaskList {

  layer: CustomDialogController = new CustomDialogController({
    builder: HmLoading(),
    customStyle: true,
    autoCancel: false,
    alignment: DialogAlignment.Center
  })

  allPage: number = 1 // 总页数先设置为1页 后续会更新

  @State
  queryParams: TaskListParamsModel = new TaskListParamsModel({
    status: TaskTypeEnum.Waiting,
    page: 1,
    pageSize: 5,
  } as TaskListParams)

  @State
  taskListData: TaskInfoItemModel[] = []

  @State
  reset: boolean = false // 用于控制重置状态

  @State
  loading: boolean = false

  @State // 控制下拉状态的变量
  refreshing: boolean = false

  // 获取底部显示的文本
  @Builder
  getBottomDisplay() {
    Row({ space: 10 }) {
      if (this.loading) {
        Text(this.allPage < this.queryParams.page ? "已经没有内容拉" : "加载数据中")
          .fontSize(14)
          .fontColor($r("app.color.text_secondary"))
        if(this.allPage >= this.queryParams.page) {
          HmLoading({
            hWidth: 20
          })
        }
      }
    }
    .height(50)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  renderItem (item: object) {
    TaskItemCard({ taskItemData: item as TaskInfoItemModel })
  }

  // 日期补零
  addZero(value: number) {
    return value.toString().padStart(2,"0")
  }

  // 控制筛选按钮可点
  getSearchEnable() {
    return !!(this.queryParams.startTime && this.queryParams.endTime)
  }

  @Builder
  getSearchForm() {
    Column() {
      Row() {
        Search({ placeholder: '请输入任务编号', value: this.queryParams.transportTaskId || '' })
          .backgroundColor($r('app.color.background_page'))
          .height(32)
          .onChange(value => {
            this.queryParams.transportTaskId = value
          })
          .onSubmit(async value => {
            this.layer.open()
            this.queryParams.page = 1
            if(value) {
              this.queryParams.startTime = ''
              this.queryParams.endTime = ''
              this.reset = false
              this.allPage = 0 // 有值意味着只有一条 因为是根据单号传的，所以不让它继续往后查 否则会重复
              this.queryParams.transportTaskId =  isNaN(parseInt(value)) ?  "0" : value
            }else {
              this.allPage = 1 // 没值意味着查不到 重新加载
              this.queryParams.transportTaskId = ""
            }
            const result = await getTaskList(this.queryParams)
            this.taskListData = result.items || []
            this.layer.close()
          })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ left: 15, right: 15, bottom: 5 })

      Row() {
        // 完成搜索页需要测试点击之后键盘和弹层同时弹出的情况
        Button(this.queryParams.startTime || '开始时间')
          .fontSize(14)
          .width(106)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onAccept: (value: DatePickerResult) => {
                this.queryParams.startTime = `${value.year}-${this.addZero(value.month! + 1)}-${this.addZero(value.day)}`
              }
            })
          })

        Text("至")
        Button(this.queryParams.endTime || '结束时间')
          .fontSize(14)
          .width(110)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onAccept: (value: DatePickerResult) => {
                this.queryParams.endTime = `${value.year}-${this.addZero(value.month! + 1)}-${this.addZero(value.day)}`
              }
            })
          })
        Button(this.reset ? "重置" : "筛选")
          .backgroundColor($r('app.color.primary_disabled'))
          .height(32)
          .width(60)
          .enabled(this.getSearchEnable())
          .onClick(async() => {
            this.queryParams.transportTaskId = ''
            if(this.reset) {
              this.queryParams.startTime = ""
              this.queryParams.endTime = ""
              this.reset = false
            }else {
              this.reset = true
            }
            this.layer.open()
            this.allPage = 1
            this.queryParams.page = 1
            await this.getTaskList(false)
            this.layer.close()
          })
      }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceAround)
    }
    .backgroundColor($r('app.color.white'))
    .padding(15)
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }

  async getTaskList(append: boolean) {
    const result = await getTaskList(this.queryParams)
    if(append) {
      this.taskListData = this.taskListData.concat(result.items || []) // 连接新的数组
    }else {
      this.taskListData = result.items || []
    }
    this.allPage = result.pages // 赋值总页数
    this.queryParams.page++ // 页码 + 1
  }

  async onRefresh () {
    this.allPage = 1
    this.queryParams.page = 1
    await this.getTaskList(false)
    this.loading = false // 这行代码必须加- 因为要考虑已经滑到底部的情况，此时loading 为true 如果不开放这个状态 无法进行上拉加载
    this.refreshing = false // 关闭下拉状态
    promptAction.showToast({
      message: '刷新成功'
    })
  }

  build() {
    Column(){
      if(this.queryParams.status === TaskTypeEnum.Finish) {
        this.getSearchForm()
      }
      HmList({
        onLoad: async () => {
          await this.getTaskList(true)
        },
        onRefresh: async () => {
          await this.onRefresh()
        },
        dataSource: $taskListData,
        renderItem: this.renderItem,
        finished: this.allPage < this.queryParams.page,
        finishText: '没啦没啦',
        loadingText: '拼命加载中'
      })
    }.height('100%')
  }
}
export default  TaskList