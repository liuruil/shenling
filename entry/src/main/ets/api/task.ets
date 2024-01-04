import { TaskListDataModel, TaskListParamsModel } from '../models'
import { Request } from '../utils'

// 获取任务列表

export const getTaskList = (params: TaskListParamsModel) => {
  return Request.get<TaskListDataModel>("/tasks/list", params)
}