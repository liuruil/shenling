import picker from '@ohos.file.picker';
import util from '@ohos.util';
import fs from '@ohos.file.fs'
import request from '@ohos.request';
import { uploadImage } from '../api'
import { ImageList } from '../models';
import { HmLoading } from '.';
import { HmPreview } from './HmPreview'
@Component
struct HmUpload {
  title: string = ""

  maxNumber:number = 3

  @State
  list: string[] = []

  @State
  index: number = -1

  preview: CustomDialogController = new CustomDialogController({
    customStyle: true,
    alignment: DialogAlignment.Center,
    builder: HmPreview({
      urls: this.list,
      selectIndex: this.index
    })
  })

  @Prop
  canUpload:boolean = true

  // 定义弹层
  layer: CustomDialogController = new CustomDialogController({
    customStyle: true,
    alignment: DialogAlignment.Center,
    builder: HmLoading({ loadingText: '图片上传中' })
  })

  @ObjectLink
  upClass: HmUploadClass

  // 弹出相册选择器
  async  selectImage () {
    let photoPicker = new picker.PhotoViewPicker();
    const result = await photoPicker.select({
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: this.maxNumber - this.upClass.images.length
    })
    if(result.photoUris?.length) {
      try {
        this.layer.open()
        // 循环处理
        let files: request.File[] = []
        const addFolderName = 'laogao'
        const defaultDir = getContext(this).cacheDir + '/' + addFolderName // 默认路径
        result.photoUris.forEach(url => {
          const file = fs.openSync(url, fs.OpenMode.READ_ONLY) // 同步读取
          const tempFileName = util.generateRandomUUID() + '.jpg' // 生成一个唯一的文件名 后面有用
          if (!fs.listFileSync(getContext(this).cacheDir).includes(addFolderName)) {
            fs.mkdirSync(defaultDir)
          }
          const fileUri = defaultDir + '/' + tempFileName
          fs.copyFileSync(file.fd, fileUri) // 同步拷贝
          files.push({
            filename: tempFileName,
            name: 'file',
            uri: `internal://cache/${addFolderName}/${tempFileName}`,
            // 这里说明一下 internal协议会自动获取当前上下文协议的沙箱路径
            type: 'jpg'
          })
        })
        // 上传文件
        const urls = await uploadImage(getContext(this), files)
        // 链接图片
        this.upClass.images = this.upClass.images.concat(urls)
        // AlertDialog.show({ message: JSON.stringify(urls) })
      } catch (error) {
        AlertDialog.show({
          message: error.message
        })
      }
      finally {
        this.layer.close()
      }
    }
    // AlertDialog.show({
    //   message: JSON.stringify(result.photoUris)
    // })
  }

  build() {
    Column() {
      Text(this.title).fontSize(14).fontColor($r("app.color.text_secondary")).margin({
        top: 16,
        bottom: 16
      })
      // 渲染图片
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.upClass.images, (item: ImageList, index: number) => {
          Stack({ alignContent: Alignment.TopEnd }) {
            Image(item.url)
              .width(95)
              .height(95)
              .borderRadius(4)
              .onClick(() => {
                this.list = this.upClass.images.map(item => item.url)
                this.index = index
                this.preview.open()
              })
             if(this.canUpload){
               // 删除图片
               Image($r('app.media.ic_btn_delete')).width(30).height(30)
                 .onClick(() => {
                   this.upClass.images = this.upClass.images.filter((_,i) => i !== index)
                 })
             }
          }.margin({ right: 15, bottom: 10 })
        })
        if(this.maxNumber > this.upClass.images.length) {
          Row() {
            Image($r("app.media.ic_add_img")).width(30).height(30)
          }
          .width(95)
          .height(95)
          .backgroundColor('#F2F2F2')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.selectImage()
          })
        }
      }
    }.alignItems(HorizontalAlign.Start).width('100%')
  }
}
export { HmUpload }

@Observed
export class HmUploadClass {
  images: ImageList[] = []
}