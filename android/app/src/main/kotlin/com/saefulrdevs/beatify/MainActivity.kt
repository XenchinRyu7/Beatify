package com.saefulrdevs.beatify

import android.content.ContentUris
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "beatify/media_store"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAudio" -> {
                    try {
                        val items = queryAudio()
                        result.success(items)
                    } catch (e: Exception) {
                        result.error("ERR_QUERY", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun queryAudio(): List<Map<String, Any?>> {
        val resolver = contentResolver
        val collection: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        }

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.ARTIST
        )

        val sortOrder = MediaStore.Audio.Media.DISPLAY_NAME + " ASC"

        val result = mutableListOf<Map<String, Any?>>()
        resolver.query(collection, projection, null, null, sortOrder)?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val nameCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
            val artistCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idCol)
                val name = cursor.getString(nameCol) ?: "Unknown"
                val artist = cursor.getString(artistCol) ?: "Unknown"
                val contentUri: Uri = ContentUris.withAppendedId(collection, id)
                result.add(mapOf(
                    "id" to id.toString(),
                    "displayName" to name,
                    "artist" to artist,
                    "uri" to contentUri.toString()
                ))
            }
        }
        return result
    }
}
