import { TabClass, TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskList from './TaskList'
@Component
export struct TaskTabs {

  @State
  tabsData: TabClass[] = [{
    name: 'waiting',
    title: '待提货'
  },{
    name: 'line',
    title: '在途'
  },{
    name: 'finish',
    title: '已完成'
  }]

  @State currentTabName: string = 'waiting'

  @Builder
  getTabBar(item: TabClass) {
    Column() {
      Text(item.title)
        .fontSize(16)
        .fontColor(this.currentTabName === item.name ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
        .fontWeight(600)
        .lineHeight(50)
        .height(50)
        .animation({
          duration: 300
        })
      Divider()
        .strokeWidth(4)
        .color($r('app.color.primary'))
        .lineCap(LineCapStyle.Round)
        .width(this.currentTabName === item.name ? 23 : 0)
        .animation({
          duration: 300
        })
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.Start }) {
      ForEach(this.tabsData, (item: TabClass) => {
        TabContent(){
          if(item.name === "waiting"){
            TaskList()
          }else if(item.name === 'line') {
            TaskList({ queryParams: new TaskListParamsModel({
              page: 1,
              pageSize: 5,
              status: TaskTypeEnum.Line
            } as TaskListParams) })
          }else if(item.name === "finish") {
            TaskList({ queryParams: new TaskListParamsModel({
              page: 1,
              pageSize: 5,
              status: TaskTypeEnum.Finish
            } as TaskListParams) })
          }
        }.tabBar(this.getTabBar(item))
      })
    }
    // .barWidth(200)
    .backgroundColor($r('app.color.background_page'))
    .animationDuration(300)
    .onChange((index: number) => {
      this.currentTabName = this.tabsData[index].name
    })
  }
}
