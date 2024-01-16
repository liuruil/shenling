import media from '@ohos.multimedia.media';
// import common from '@ohos.app.ability.common';

export class AVPlayerClass {
  static avPlayer: media.AVPlayer | null = null
  static audioName: string = ''
  static isSettingBack: boolean = false

  static async playAudio (audioName: string, context: Context){
    if(!AVPlayerClass.avPlayer) {
      AVPlayerClass.avPlayer = await media.createAVPlayer() // 如果avplayer不存在则创建
    }
    if(audioName) {
      AVPlayerClass.audioName = audioName // 说明没有设置过 或者和之前不一样
      AVPlayerClass.setAvPlayerName(context)
    }
  }
  // 设置播放源
  static async setAvPlayerName (context: Context) {
    try {
      let fileDescriptor = await context.resourceManager.getRawFd(AVPlayerClass.audioName);
      let avFileDescriptor: media.AVFileDescriptor =
        { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length }
      if(!AVPlayerClass.isSettingBack) {
        AVPlayerClass.setAvPlayerCallBack() // 设置回调
      }
      if(AVPlayerClass.avPlayer) {
        AVPlayerClass.avPlayer.fdSrc = avFileDescriptor // 设置播放源
      }
    }catch (error) {
      AlertDialog.show({
        message: error.message
      })
    }

  }

  static setAvPlayerCallBack() {
    if(AVPlayerClass.avPlayer) {
      AVPlayerClass.isSettingBack = true
      // seek操作结果回调函数
      AVPlayerClass.avPlayer!.on('seekDone', (seekDoneTime: number) => {
        // console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
        AVPlayerClass.avPlayer!.play() // 回拨到0秒后 开始播放
      })
      // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
      // 状态机变化回调函数
      AVPlayerClass.avPlayer!.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
        switch (state) {
        // case 'idle': // 成功调用reset接口后触发该状态机上报
        //   console.info('AVPlayer state idle called.');
        // AVPlayerClass.avPlayer!.release(); // 调用release接口销毁实例对象
        //    break;
          case 'initialized': // avplayer 设置播放源后触发该状态上报
            console.info('AVPlayer state initialized called.');
            AVPlayerClass.avPlayer!.prepare();
            break;
          case 'prepared': // prepare调用成功后上报该状态机
            console.info('AVPlayer state prepared called.');
            AVPlayerClass.avPlayer!.seek(0) // 准备好之后 将音频回拨到0秒
            break;
          case 'playing': // play成功调用后触发该状态机上报
            console.info('AVPlayer state playing called.');
            break;
          case 'paused': // pause成功调用后触发该状态机上报
            console.info('AVPlayer state paused called.');
            break;
          case 'completed': // 播放结束后触发该状态机上报
            console.info('AVPlayer state completed called.');
            AVPlayerClass.avPlayer!.reset(); //调用播放结束接口
            break;
          case 'stopped': // stop接口成功调用后触发该状态机上报
            console.info('AVPlayer state stopped called.');
            break;
          case 'released':
            console.info('AVPlayer state released called.');
            break;
          default:
            console.info('AVPlayer state unknown called.');
            break;
        }
      })
    }

  }

}