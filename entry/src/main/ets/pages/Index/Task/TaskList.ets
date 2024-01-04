import { getTaskList } from '../../../api'
import { HmLoading } from '../../../components'
import TaskItemCard from '../../../components/TaskItemCard'
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

  async getTaskList() {
    const result = await getTaskList(this.queryParams)
    this.taskListData = this.taskListData.concat(result.items) // 连接新的数组
    this.allPage = result.pages // 赋值总页数
    this.queryParams.page++ // 页码+1
  }

  build() {
    List () {
      ForEach(this.taskListData, (item: TaskInfoItemModel) => {
        ListItem(){
          TaskItemCard({taskItemData:item})
        }
      })
      ListItem(){
        this.getBottomDisplay() // 底部显示内容
      } // 为了防止第一次不触发的问题

    }.onReachEnd(async () => {
      if(this.allPage >= this.queryParams.page) {
        if(!this.loading){
          this.loading = true
          await this.getTaskList()
          this.loading = this.allPage < this.queryParams.page ? true : false
        }
      }
    })
  }
}
export default  TaskList