import hilog from '@ohos.hilog'

const DOMAIN = 0xFFFF
const PREFIX = '__INTERVIEW__'
const FORMAT = '%{public}s, %{public}s'

export class Logger {
  static debug(...args: string[]) {
    hilog.debug(DOMAIN, PREFIX, FORMAT, args)
  }

  static info(...args: string[]) {
    hilog.info(DOMAIN, PREFIX, FORMAT, args)
  }

  static warn(...args: string[]) {
    hilog.warn(DOMAIN, PREFIX, FORMAT, args)
  }

  static error(...args: string[]) {
    hilog.error(DOMAIN, PREFIX, FORMAT, args)
  }

  static fatal(...args: string[]) {
    hilog.fatal(DOMAIN, PREFIX, FORMAT, args)
  }

  static isLoggable(level: hilog.LogLevel) {
    return hilog.isLoggable(DOMAIN, PREFIX, level)
  }
}