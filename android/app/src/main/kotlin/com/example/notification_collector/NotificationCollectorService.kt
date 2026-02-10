package com.example.notification_collector

import android.app.Notification
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class NotificationCollectorService : NotificationListenerService() {

    companion object {
        private const val TAG = "NotificationCollector"
        private const val CHANNEL_NAME = "notification_collector_channel"
        private var methodChannel: MethodChannel? = null
        
        fun initialize(engine: FlutterEngine) {
            methodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        sbn?.let {
            try {
                val notificationData = extractNotificationData(it)
                sendToFlutter(notificationData)
            } catch (e: Exception) {
                Log.e(TAG, "Error processing notification: ${e.message}", e)
            }
        }
    }

    private fun extractNotificationData(sbn: StatusBarNotification): Map<String, Any> {
        val notification = sbn.notification
        val extras = notification.extras
        val packageName = sbn.packageName
        
        val truncatedMessage = extractTruncatedMessage(extras)
        val senderName = extractSenderName(extras, packageName)
        val messageType = determineMessageType(packageName)
        val fullMessage = extractFullMessage(packageName, senderName, truncatedMessage, extras)
        
        return mapOf(
            "packageName" to packageName,
            "senderName" to senderName,
            "truncatedMessage" to truncatedMessage,
            "fullMessage" to fullMessage,
            "messageType" to messageType,
            "timestamp" to System.currentTimeMillis()
        )
    }

    private fun extractTruncatedMessage(extras: Bundle): String {
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
        if (!text.isNullOrEmpty()) return text.trim()
        
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()
        if (!subText.isNullOrEmpty()) return subText.trim()
        
        return "NOT_AVAILABLE"
    }

    private fun extractSenderName(extras: Bundle, packageName: String): String {
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
        if (!title.isNullOrEmpty()) return title.trim()
        
        return packageName
    }

    private fun determineMessageType(packageName: String): String {
        return when {
            packageName.contains("sms") || packageName.contains("mms") || 
            packageName.contains("messaging") -> "SMS"
            packageName.contains("whatsapp") -> "WhatsApp"
            packageName.contains("telegram") -> "Telegram"
            packageName.contains("messenger") -> "Messenger"
            else -> "Other"
        }
    }

    private fun extractFullMessage(
        packageName: String, 
        senderName: String,
        truncatedMessage: String,
        extras: Bundle
    ): String {
        if (packageName.contains("sms") || packageName.contains("messaging")) {
            val smsMessage = getLatestSmsFromSender(senderName)
            if (smsMessage != null) return smsMessage
        }
        
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
        if (!bigText.isNullOrEmpty() && bigText != truncatedMessage) {
            return bigText.trim()
        }
        
        return "NOT_AVAILABLE"
    }

    private fun getLatestSmsFromSender(senderAddress: String): String? {
        try {
            val uri = Uri.parse("content://sms/inbox")
            val projection = arrayOf("address", "body", "date")
            val selection = "address = ?"
            val selectionArgs = arrayOf(senderAddress)
            val sortOrder = "date DESC LIMIT 1"
            
            val cursor: Cursor? = contentResolver.query(
                uri, projection, selection, selectionArgs, sortOrder
            )
            
            cursor?.use {
                if (it.moveToFirst()) {
                    val bodyIndex = it.getColumnIndex("body")
                    if (bodyIndex >= 0) {
                        return it.getString(bodyIndex)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error reading SMS: ${e.message}", e)
        }
        
        return null
    }

    private fun sendToFlutter(data: Map<String, Any>) {
        methodChannel?.invokeMethod("onNotificationReceived", data)
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "Notification Listener Connected")
    }
}