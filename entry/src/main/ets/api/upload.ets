import request from '@ohos.request'
import { BASE_URL, TOKEN_KEY } from '../constants'
import { ImageList, ImageListModel } from '../models'
import { Request as RequestClass  } from '../utils/request'

class FileParams {
  imageName: string = ""
}

export const uploadImage = (context: Context, files: request.File[]) => {
  const config: request.UploadConfig = {
    url: `${BASE_URL}/files/imageUpload`,
    method: 'POST',
    header: {
      'Accept': '*/*',
      'Authorization': `${AppStorage.Get<string>(TOKEN_KEY)}`,
      'Content-Type': 'multipart/form-data'
    },
    files,
    data: []
  }
  try {
    return new Promise<ImageList[]>(async (resolve,reject)=>{
      const UploadTask = await request.uploadFile(context, config)
      UploadTask.on('fail', (state) => {
        AlertDialog.show({
          message: '图片上传失败'
        })
      })
      UploadTask.on('complete', async () => {
        const result = await Promise.all<string>(files.map(item => RequestClass.get<string>("/files/imageUrl", {
          imageName: item.filename.slice(0, item.filename.indexOf('.'))
        } as FileParams))) // 因为在Next版本里面，不能将字面量应用于object
        resolve(result.map(url => new ImageListModel({ url })))
      })
    })
  }catch(error) {
    AlertDialog.show({
      message: error.message
    })
  }

}