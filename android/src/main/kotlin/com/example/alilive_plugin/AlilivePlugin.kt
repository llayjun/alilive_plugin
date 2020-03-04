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

    fun registerWith(registrar: Registrar) {
        val channel = MethodChannel(registrar.messenger(), "com.czh.tvmerchantapp/plugin")
        channel.setMethodCallHandler(AlilivePlugin())
    }

    companion object {
        @JvmField
        var context: Context? = null
        // This static function is optional and equivalent to onAttachedToEngine. It supports the old
// pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
// plugin registration via this function while apps migrate to use the new Android APIs
// post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
//
// It is encouraged to share logic between onAttachedToEngine and registerWith to keep
// them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
// depending on the user's project. onAttachedToEngine or registerWith must both be defined
// in the same class.

    }
}
