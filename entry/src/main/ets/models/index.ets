export * from './advert'
export * from './user'
export * from './tabs'
export * from './task'
export * from  './router'
export * from './task_detail'
export * from './pickup'
export * from './deliver'
export * from './car_record'
export * from './delay'
export * from './exception'
export * from './location'
export * from './message'
export * from './car'
export * from './base_datasource'
export class ResponseData<T> {
  code: number = 0
  msg: string = ""
  data: T | null = null // 这里应该必须只能这么声明！！！！
}

export interface EmptyInterface {}