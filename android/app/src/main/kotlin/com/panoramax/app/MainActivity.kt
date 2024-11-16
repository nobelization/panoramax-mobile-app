package com.panoramax.app

import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.media.ExifInterface
import android.provider.MediaStore
import android.database.Cursor
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream


class MainActivity : FlutterActivity() {

    private val CHANNEL = "app.panoramax.beta/data"

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        if (Intent.ACTION_SEND == intent.action && intent.type != null) {
            handleSendImage(intent) 
        } else if (Intent.ACTION_SEND_MULTIPLE == intent.action && intent.type != null) {
            handleSendMultipleImages(intent) 
        }
    }

    private fun handleSendImage(intent: Intent) {
        val imageUri: Uri? = intent.getParcelableExtra(Intent.EXTRA_STREAM)
        imageUri?.let { uri ->
            sendUriToFlutter(listOf(uri))
        }
    }

    private fun handleSendMultipleImages(intent: Intent) {
        val imageUris: ArrayList<Uri>? = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM)
        imageUris?.let { uris ->
                sendUriToFlutter(uris)
        }
    }

    fun getFilePathFromUri(context: Context, uri: Uri): String? {
        val contentResolver: ContentResolver = context.contentResolver
        val fileName = getFileName(context, uri)
            Log.d("MainActivity", "fileName = $fileName")

        val tempFile = File(context.cacheDir, fileName ?: "temp_file")

        contentResolver.openInputStream(uri)?.use { inputStream ->
            FileOutputStream(tempFile).use { outputStream ->
                inputStream.copyTo(outputStream)
            }
        }

        return tempFile.absolutePath // Retourner le chemin du fichier temporaire
    }

    private fun getFileName(context: Context, uri: Uri): String? {
        var name: String? = null
        val returnCursor = context.contentResolver.query(uri, null, null, null, null)
        returnCursor?.use { cursor ->
            val nameIndex =
                cursor.getColumnIndex(android.provider.MediaStore.Images.Media.DISPLAY_NAME)
            if (cursor.moveToFirst()) {
                name = cursor.getString(nameIndex)
            }
        }
        return name
    }

    private fun sendUriToFlutter(uris: List<Uri>) {
        val listUris = mutableListOf<String>()
        Log.d("MainActivity", "sendUriToFlutter")
        for(uri in uris) {
            val filePath = getFilePathFromUri(context, uri)
            if (filePath != null) {
                Log.d("MainActivity", "uris $filePath")
                listUris.add(filePath)
            }
        }

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL).invokeMethod(
                "sendUri",
                listUris
            )
        }
    }
}