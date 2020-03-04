package com.example.alilive_plugin

import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull;
import com.example.alilive_plugin.boast.PlayActivity
import com.example.alilive_plugin.live.SecondActivity
import com.example.alilive_plugin.live.ToastUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** AlilivePlugin */
public class AlilivePlugin: FlutterPlugin, MethodCallHandler {

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "com.czh.tvmerchantapp/plugin")
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(AlilivePlugin())
    }

    companion object {
        @JvmField
        var context: Context? = null

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "com.czh.tvmerchantapp/plugin")
            channel.setMethodCallHandler(AlilivePlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android版本" + Build.VERSION.RELEASE)
            "jumpToLivePlay" -> {
                val liveUrl = call.arguments.toString()
                ToastUtils.show("跳转到直播界面，地址是$liveUrl")
                val intent = Intent(context, SecondActivity::class.java)
                intent.putExtra(SecondActivity.LIVE_URL_KEY, liveUrl)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context!!.startActivity(intent)
            }
            "jumpToBoast" -> {
                val boastUrl = call.arguments.toString()
                ToastUtils.show("跳转到播放界面，地址是$boastUrl")
                val intentBoast = Intent(context, PlayActivity::class.java)
                intentBoast.putExtra(PlayActivity.LIVE_URL_KEY, boastUrl)
                intentBoast.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context!!.startActivity(intentBoast)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

}
