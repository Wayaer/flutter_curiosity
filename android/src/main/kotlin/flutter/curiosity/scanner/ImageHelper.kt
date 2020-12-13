package flutter.curiosity.scanner

import android.content.Context
import android.content.ContextWrapper
import android.graphics.Bitmap
import java.util.*
import kotlin.math.max
import kotlin.math.min

class ImageHelper(base: Context) : ContextWrapper(base) {


    /**
     * 根据Bitmap的ARGB值生成YUV420SP数据。
     *
     * @param inputWidth  image width
     * @param inputHeight image height
     * @param scaled      bmp
     * @return YUV420SP数组
     */
    fun getYUV420(inputWidth: Int, inputHeight: Int, scaled: Bitmap): ByteArray {
        var yuvs = ByteArray(0)
        val argb = IntArray(inputWidth * inputHeight)
        scaled.getPixels(argb, 0, inputWidth, 0, 0, inputWidth, inputHeight)
        /**
         * 需要转换成偶数的像素点，否则编码YUV420的时候有可能导致分配的空间大小不够而溢出。
         */
        val requiredWidth = if (inputWidth % 2 == 0) inputWidth else inputWidth + 1
        val requiredHeight = if (inputHeight % 2 == 0) inputHeight else inputHeight + 1
        val byteLength = requiredWidth * requiredHeight * 3 / 2
        if (yuvs.size < byteLength) {
            yuvs = ByteArray(byteLength)
        } else {
            Arrays.fill(yuvs, 0.toByte())
        }
        encodeYUV420(yuvs, argb, inputWidth, inputHeight)
        scaled.recycle()
        return yuvs
    }

    /**
     * RGB转YUV420sp
     *
     * @param yuv420sp inputWidth * inputHeight * 3 / 2
     * @param argb     inputWidth * inputHeight
     * @param width    image width
     * @param height   image height
     */
    private fun encodeYUV420(yuv420sp: ByteArray, argb: IntArray, width: Int, height: Int) {
        // 帧图片的像素大小
        val frameSize = width * height
        // ---YUV数据---
        var y: Int
        var u: Int
        var v: Int
        // Y的index从0开始
        var yIndex = 0
        // UV的index从frameSize开始
        var uvIndex = frameSize
        // ---颜色数据---
        var r: Int
        var g: Int
        var b: Int
        var rgbIndex = 0
        // ---循环所有像素点，RGB转YUV---
        for (j in 0 until height) {
            for (i in 0 until width) {
                r = argb[rgbIndex] and 0xff0000 shr 16
                g = argb[rgbIndex] and 0xff00 shr 8
                b = argb[rgbIndex] and 0xff
                //
                rgbIndex++
                // well known RGB to YUV algorithm
                y = (66 * r + 129 * g + 25 * b + 128 shr 8) + 16
                u = (-38 * r - 74 * g + 112 * b + 128 shr 8) + 128
                v = (112 * r - 94 * g - 18 * b + 128 shr 8) + 128
                y = max(0, min(y, 255))
                u = max(0, min(u, 255))
                v = max(0, min(v, 255))
                // NV21 has a plane of Y and interleaved planes of VU each sampled by a factor of 2
                // meaning for every 4 Y pixels there are 1 V and 1 U. Note the sampling is every other
                // pixel AND every other scan line.
                // ---Y---
                yuv420sp[yIndex++] = y.toByte()
                // ---UV---
                if (j % 2 == 0 && i % 2 == 0) {
                    //
                    yuv420sp[uvIndex++] = v.toByte()
                    //
                    yuv420sp[uvIndex++] = u.toByte()
                }
            }
        }
    }


}