import { CarRecordTypeModel, DelayParamsTypeModel, DeliverParamsTypeModel, TaskListDataModel, TaskListParamsModel } from '../models'
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

// 交货
export const deliver = (data: DeliverParamsTypeModel) => {
  return Request.post<null>("/tasks/deliver", data)
}

export const carRecord = (data: CarRecordTypeModel) => {
  return Request.post<null>("/tasks/truckRegistration", data)
}

// 延迟收货
export const delay = (data: DelayParamsTypeModel) => {
  return Request.put<null>("/tasks/delay", data)
}