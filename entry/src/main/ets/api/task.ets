import { TaskListDataModel, TaskListParamsModel } from '../models'
import { Request } from '../utils'
import {  TaskDetailInfoModel,PickUpParamsModel } from '../models'

// 提货
export const pickUp = (data: PickUpParamsModel) => {
  return Request.post<null>("/tasks/takeDelivery", data)
}
// 获取任务列表

export const getTaskList = (params: TaskListParamsModel) => {
  return Request.get<TaskListDataModel>("/tasks/list", params)
}

export const getTaskDetail = (id: string) => {
  return Request.get<TaskDetailInfoModel>(`/tasks/details/${id}`)
}