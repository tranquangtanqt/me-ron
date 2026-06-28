package com.elriztechnology.flutter_pos

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "me_ron/media_store"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler {
            call,
            result ->
            when (call.method) {
                "saveFileToDownloads" -> {
                    val fileName = call.argument<String>("fileName") ?: "backup.tsv"
                    val relativePath = call.argument<String>("relativePath") ?: "Download/MeRon"
                    val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                    val bytes = call.argument<ByteArray>("bytes") ?: byteArrayOf()

                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val values = ContentValues().apply {
                                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                                put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                            }

                            val resolver = applicationContext.contentResolver
                            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                            if (uri == null) {
                                result.error("save_failed", "Không thể tạo mục trong MediaStore", null)
                                return@setMethodCallHandler
                            }

                            resolver.openOutputStream(uri)?.use { outputStream ->
                                outputStream.write(bytes)
                            }
                            result.success(relativePath + "/" + fileName)
                        } else {
                            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                            val targetDir = File(downloadsDir, relativePath.removePrefix("Download/"))
                            if (!targetDir.exists()) {
                                targetDir.mkdirs()
                            }
                            val targetFile = File(targetDir, fileName)
                            FileOutputStream(targetFile).use { it.write(bytes) }
                            result.success(targetFile.absolutePath)
                        }
                    } catch (e: Exception) {
                        result.error("save_failed", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
