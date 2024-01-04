export * from './advert'
export * from './user'
export * from './tabs'
export * from './task'
export * from  './router'
export * from './task_detail'
export class ResponseData<T> {
  code: number = 0
  msg: string = ""
  data: T | null = null // 这里应该必须只能这么声明！！！！
}