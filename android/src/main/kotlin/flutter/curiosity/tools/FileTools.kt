package flutter.curiosity.tools

import android.util.Log
import flutter.curiosity.BuildConfig
import flutter.curiosity.CuriosityPlugin.Companion.call
import java.io.*
import java.text.DecimalFormat
import java.util.*
import java.util.zip.ZipEntry
import java.util.zip.ZipFile

object FileTools {

    /**
     * 获取指定文件夹的大小
     *
     * @param file
     * @return
     */
    fun getDirectorySize(file: File): String {
        val size = StringBuilder()
        val list = file.listFiles()
                ?: //4.2的模拟器空指针。
                return "0.00KB" //文件夹目录下的所有文件
        for (value in list) {
            if (value.isDirectory) { //判断是否父目录下还有子目录
                size.append(getDirectorySize(value))
            } else {
                size.append(getFileSize(value))
            }
        }
        return if (size.toString() == "") "0.00KB" else size.toString()
    }

    /**
     * 获取指定文件的大小
     *
     * @return
     * @throws Exception
     */
    fun getFileSize(file: File): String {
        var size: Long = 0
        if (file.exists()) {
            var fis: FileInputStream? = null
            try {
                fis = FileInputStream(file) //使用FileInputStream读入file的数据流
                size = fis.available().toLong() //文件的大小
            } catch (e: IOException) {
                e.printStackTrace()
            } finally {
                try {
                    if (BuildConfig.DEBUG && fis == null) {
                        error("Assertion failed")
                    }
                    fis!!.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
        }
        return formatFileSize(size)
    }

    /**
     * 转换文件大小
     *
     * @param fileSize
     * @return
     */
    private fun formatFileSize(fileSize: Long): String {
        val df = DecimalFormat("#.00")
        val fileSizeString: String
        val wrongSize = "0B"
        if (fileSize == 0L) {
            return wrongSize
        }
        fileSizeString = when {
            fileSize < 1024 -> {
                df.format(fileSize.toDouble()) + "B"
            }
            fileSize < 1048576 -> {
                df.format(fileSize.toDouble() / 1024) + "KB"
            }
            fileSize < 1073741824 -> {
                df.format(fileSize.toDouble() / 1048576) + "MB"
            }
            else -> {
                df.format(fileSize.toDouble() / 1073741824) + "GB"
            }
        }
        return fileSizeString
    }

    /**
     * 给定根目录，返回一个相对路径所对应的实际文件名.
     *
     * @param baseDir     指定根目录
     * @param absFileName 相对路径名，来自于ZipEntry中的name
     * @return java.io.File 实际的文件
     */
    private fun getRealFileName(baseDir: String, absFileName: String): File {
        val dirs = absFileName.split("/").toTypedArray()
        var ret = File(baseDir)
        var substr: String
        if (dirs.size > 1) {
            for (i in 0 until dirs.size - 1) {
                substr = dirs[i]
                try {
                    substr = String(substr.toByteArray(charset("8859_1")))//, "GB2312")
                } catch (e: UnsupportedEncodingException) {
                    e.printStackTrace()
                }
                ret = File(ret, substr)
            }
            if (!ret.exists()) ret.mkdirs()
            substr = dirs[dirs.size - 1]
            try {
                substr = String(substr.toByteArray(charset("8859_1")))//, "GB2312")
            } catch (e: UnsupportedEncodingException) {
                e.printStackTrace()
            }
            ret = File(ret, substr)
            return ret
        }
        return ret
    }


    /**
     * @param content
     */
    fun logInfo(content: String) {
        Log.i("LogInfo==> ", content)
    }

    /**
     * 判断是否有该路径
     *
     * @param path
     * @return
     */
    fun isDirectoryExist(path: String): Boolean {
        val file = File(path)
        return file.exists()
    }


    /**
     * 解压文件
     *
     */
    fun unZipFile(): String {
        val zipPath = call.argument<String>("filePath") ?: return Tools.resultError()
        return if (isDirectoryExist(zipPath)) {
            val pathArr = zipPath.split("/").toTypedArray()
            val fileName = pathArr[pathArr.size - 1]
            val filePath = zipPath.substring(0, zipPath.length - fileName.length)
            val file = ZipFile(File(zipPath))
            val zList = file.entries()
            val buf = ByteArray(1024)
            while (zList.hasMoreElements()) {
                val ze: ZipEntry = zList.nextElement() as ZipEntry
                if (ze.isDirectory) {
                    var dirStr = filePath + ze.name
                    dirStr = String(dirStr.toByteArray(charset("8859_1")))
                    val f = File(dirStr)
                    f.mkdir()
                    continue
                }
                val os = BufferedOutputStream(FileOutputStream(getRealFileName(filePath, ze.getName())))
                val inputStream = BufferedInputStream(file.getInputStream(ze))
                var readLen = 0
                while (inputStream.read(buf, 0, 1024).also { readLen = it } != -1) {
                    os.write(buf, 0, readLen)
                }
                inputStream.close()
                os.close()
            }
            file.close()
            Tools.resultSuccess()
        } else {
            Tools.resultNot("not file")
        }
    }


}