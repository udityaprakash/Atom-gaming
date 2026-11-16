package com.example.atom

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.atom/file_picker"
    private val PICK_DB_FILE_REQUEST = 1001
    private val REQUEST_INSTALL_PERMISSION = 1002
    private var pendingResult: MethodChannel.Result? = null
    private var pendingApkPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickBackupFile" -> {
                    if (pendingResult != null) {
                        result.error("ALREADY_ACTIVE", "A file picker is already open", null)
                        return@setMethodCallHandler
                    }
                    pendingResult = result

                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "*/*"
                    }
                    startActivityForResult(intent, PICK_DB_FILE_REQUEST)
                }
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath == null) {
                        result.error("INVALID_PATH", "File path cannot be null", null)
                        return@setMethodCallHandler
                    }
                    val file = File(filePath)
                    if (!file.exists()) {
                        result.error("FILE_NOT_FOUND", "APK file does not exist", null)
                        return@setMethodCallHandler
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        if (!packageManager.canRequestPackageInstalls()) {
                            pendingApkPath = filePath
                            val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                                data = Uri.parse("package:$packageName")
                            }
                            startActivityForResult(intent, REQUEST_INSTALL_PERMISSION)
                            result.success("REQUESTING_PERMISSION")
                            return@setMethodCallHandler
                        }
                    }

                    triggerInstall(file)
                    result.success("INSTALLING")
                }
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.error("INVALID_URL", "URL cannot be null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun triggerInstall(file: File) {
        val uri = FileProvider.getUriForFile(this, "${applicationContext.packageName}.fileprovider", file)
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == PICK_DB_FILE_REQUEST) {
            val result = pendingResult
            pendingResult = null

            if (resultCode == Activity.RESULT_OK && data != null && data.data != null) {
                val uri: Uri = data.data!!
                try {
                    val inputStream = contentResolver.openInputStream(uri)
                    val tempFile = File(cacheDir, "imported_backup.db")
                    val outputStream = FileOutputStream(tempFile)
                    inputStream?.use { input ->
                        outputStream.use { output ->
                            input.copyTo(output)
                        }
                    }
                    result?.success(tempFile.absolutePath)
                } catch (e: Exception) {
                    result?.error("IMPORT_FAILED", e.localizedMessage, null)
                }
            } else {
                result?.success(null)
            }
        } else if (requestCode == REQUEST_INSTALL_PERMISSION) {
            val apkPath = pendingApkPath
            pendingApkPath = null
            if (apkPath != null) {
                val file = File(apkPath)
                if (file.exists()) {
                    triggerInstall(file)
                }
            }
        }
    }
}
