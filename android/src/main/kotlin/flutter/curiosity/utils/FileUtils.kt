package flutter.curiosity.utils

import android.util.Log
import io.flutter.plugin.common.MethodCall
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.io.UnsupportedEncodingException
import java.text.DecimalFormat
import java.util.*

object FileUtils {
    private fun deleteDirWithFile(dir: File) {
        if (!dir.exists()) return
        if (dir.isFile) {
            dir.delete()
            return
        }
        val files = dir.listFiles()
        for (file in files) {
            if (file.isFile) file.delete() // 删除所有文件
            else if (file.isDirectory) deleteDirWithFile(file) // 递规的方式删除文件夹
        }
        dir.delete() // 删除目录本身
    }

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
                    assert(fis != null)
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
    fun getRealFileName(baseDir: String, absFileName: String): File {
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
     * 判断是否有该路径,如果没有就创建,传入路径
     *
     * @param directory
     * @return
     */
    fun createDirectory(directory: String): Boolean {
        val file = File(directory)
        if (!file.exists()) {
            if (file.mkdirs()) {
                return true
            }
        }
        return true
    }

    /**
     * 删除文件和文件夹里面的文件
     *
     * @param path
     */
    fun deleteFile(path: String?) {
        val dir = File(path)
        deleteDirWithFile(dir)
    }

    /**
     * 删除文件夹内的文件（不删除文件夹）
     *
     * @param path
     */
    fun deleteDirectory(path: String?) {
        if (path == null) return
        val dir = File(path).listFiles()
        for (file in dir) {
            if (file.isFile) {
                file.delete() // 删除所有文件
            } else if (file.isDirectory) {
                deleteDirWithFile(file)
            }
        }

    }

    /**
     * 获取路径下所有文件及文件夹名
     *
     * @return
     */
    fun getDirectoryAllName(call: MethodCall): MutableList<String> {
        val path = call.argument<String>("path")
        assert(path != null)
        val isAbsolutePath = Objects.requireNonNull<Boolean>(call.argument("isAbsolutePath"))
        val nameList: MutableList<String> = ArrayList()
        if (!isDirectoryExist(path!!)) {
            nameList.add("path not exist")
            return nameList
        }
        val file = File(path)
        if (!file.isDirectory) {
            nameList.add("path is not Directory")
            return nameList
        }
        val files = file.listFiles()
        if (files != null && files.isNotEmpty()) {
            for (value in files) {
                nameList.add(if (isAbsolutePath) value.absolutePath else value.name)
            }
        }
        return nameList
    }
}