import { Log, MethodCall } from "@ohos/flutter_ohos"
import fs from "@ohos.file.fs"
import { common } from "@kit.AbilityKit"
import { photoAccessHelper } from "@kit.MediaLibraryKit"
import { image } from "@kit.ImageKit"
import fileUri from "@ohos.file.fileuri"
import CuriosityPlugin from "./CuriosityPlugin"

// 定义支持的图片和视频扩展名集合
const IMAGE_EXTENSIONS: Set<string> = new Set([
  'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heif', 'heic',
  'svg', 'tiff', 'raw', 'ico'
]);

const VIDEO_EXTENSIONS: Set<string> = new Set([
  'mp4', 'mov', 'avi', 'flv', 'wmv', 'mkv', 'webm', 'mpeg',
  'mpg', '3gp', 'm4v', 'rmvb', 'ts', 'mts'
]);

export default class ImageGalleryTools {
  static async saveBytesImageToGallery(context: common.Context, call: MethodCall): Promise<boolean> {
    let byteArray = call.argument("bytes") as Uint8Array
    let quality = call.argument("quality") as number
    let fileName = call.argument("name") as string
    let extension = call.argument("extension") as string
    if (byteArray == null || extension == null) {
      return false
    }
    let sourcePath: string = ''
    try {
      sourcePath = await ImageGalleryTools.saveCacheDir(context, byteArray, quality, extension);
    } catch (err) {
      Log.e(`${CuriosityPlugin.logTag} saveCacheDir error:`, err.message);
      return false;
    }
    try {
      return await ImageGalleryTools.saveToGallery(context, sourcePath, fileName, extension,
        photoAccessHelper.PhotoType.IMAGE)
    } catch (err) {
      Log.e(`${CuriosityPlugin.logTag} saveToGallery error:`, err.message);
      return false;
    } finally {
      try {
        fs.unlinkSync(sourcePath)
      } catch (err) {
        Log.e(`${CuriosityPlugin.logTag} unlink cache image error:`, err.message);
      }
    }
  }

  static async saveFilePathToGallery(context: common.Context, call: MethodCall): Promise<boolean> {
    let sourcePath = call.argument('path') as string
    let fileName = call.argument('name') as string
    let extension = call.argument('extension') as string
    if (!fs.accessSync(sourcePath)) {
      return false;
    }
    let photoType = ImageGalleryTools.getMIMEType(extension);
    if (photoType == null) {
      return false
    }
    return await ImageGalleryTools.saveToGallery(context, sourcePath, fileName, extension, photoType)
  }

  // 获取类型
  static getMIMEType(extension: string): photoAccessHelper.PhotoType | null {
    if (IMAGE_EXTENSIONS.has(extension)) {
      return photoAccessHelper.PhotoType.IMAGE;
    } else if (VIDEO_EXTENSIONS.has(extension)) {
      return photoAccessHelper.PhotoType.VIDEO;
    }
    return null;
  }

  // 保存
  static async saveToGallery(context: common.Context, sourcePath: string, title: string, fileNameExtension: string,
    photoType: photoAccessHelper.PhotoType): Promise<boolean> {
    let sourceFile: fs.File | null = null
    let targetFile: fs.File | null = null
    try {
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      let sourceFileUri = fileUri.getUriFromPath(sourcePath);
      let targetFileUris = await phAccessHelper.showAssetsCreationDialog([sourceFileUri], [{
        title,
        fileNameExtension,
        photoType,
        subtype: photoAccessHelper.PhotoSubtype.DEFAULT
      }]);
      if (targetFileUris == null || targetFileUris.length == 0) {
        return false;
      }
      sourceFile = await fs.open(sourceFileUri, fs.OpenMode.READ_ONLY);
      targetFile = await fs.open(targetFileUris[0], fs.OpenMode.READ_WRITE);
      fs.copyFileSync(sourceFile.fd, targetFile.fd);
      return true;
    } catch (err) {
      Log.e(`${CuriosityPlugin.logTag} ImageGalleryTools error:`, err.message);
      return false;
    } finally {
      if (sourceFile != null) {
        try {
          fs.closeSync(sourceFile);
        } catch (err) {
          Log.e(`${CuriosityPlugin.logTag} close source file error:`, err.message);
        }
      }
      if (targetFile != null) {
        try {
          fs.closeSync(targetFile);
        } catch (err) {
          Log.e(`${CuriosityPlugin.logTag} close target file error:`, err.message);
        }
      }
    }
  }

  // 将图片暂存到缓存压缩图片
  static async saveCacheDir(context: common.Context, uint8Array: Uint8Array, quality: number,
    extension: string): Promise<string> {
    let filePath: string = context.cacheDir + '/cache_image_source_' + Date.now() + '_' +
      Math.floor(Math.random() * 1000000) + '.' + extension;
    let outputFile = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    let outputFileClosed = false
    try {
      await fs.write(outputFile.fd, uint8Array.buffer);
      const imagePacker: image.ImagePacker = image.createImagePacker();
      const imageSource: image.ImageSource = image.createImageSource(outputFile.fd);
      const imageBuffer: ArrayBuffer = await imagePacker.packing(imageSource, { format: "image/" + extension, quality });
      await fs.close(outputFile.fd)
      outputFileClosed = true
      let outputImage = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      try {
        await fs.write(outputImage.fd, imageBuffer);
      } finally {
        await fs.close(outputImage.fd)
      }
      return filePath;
    } catch (err) {
      try {
        fs.unlinkSync(filePath)
      } catch (e) {
        // 忽略清理失败，保留原始异常
      }
      throw err;
    } finally {
      if (!outputFileClosed) {
        try {
          await fs.close(outputFile.fd)
        } catch (e) {
          // 忽略关闭失败，保留原始异常
        }
      }
    }
  }
}
