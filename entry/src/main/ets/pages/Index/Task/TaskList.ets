import promptAction from '@ohos.promptAction'
import { getTaskList } from '../../../api'
import { HmLoading,HmList } from '../../../components'
import TaskItemCard from './TaskItemCard'
import { TaskInfoItemModel, TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models/task'
@Preview
@Component
struct TaskList {

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
  loading: boolean = false

  @State // 控制下拉状态的变量
  refreshing: boolean = false

  // aboutToAppear() {
  //   this.getTaskList()
  // }

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

  async getTaskList(append: boolean) {
    const result = await getTaskList(this.queryParams)
    if(append) {
      this.taskListData = this.taskListData.concat(result.items) // 连接新的数组
    }else {
      this.taskListData = result.items
    }
    this.allPage = result.pages // 赋值总页数
    this.queryParams.page++ // 页码+1
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
  }
}
export default  TaskList