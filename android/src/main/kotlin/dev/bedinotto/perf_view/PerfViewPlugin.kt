package dev.bedinotto.perf_view


import android.annotation.TargetApi
import android.app.ActivityManager
import android.content.Context
import android.net.TrafficStats
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** PerfViewPlugin */
class PerfViewPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var context: Context
  private lateinit var channel : MethodChannel
  private var uid : Int = 0
  private var rxBytes : Array<Long> = arrayOf(0,0)
  private var txBytes : Array<Long> = arrayOf(0,0)

  private var rxPackages : Array<Long> = arrayOf(0,0)
  private var txPackages : Array<Long> = arrayOf(0,0)


  private val handler = Handler(Looper.getMainLooper())
  private var isRunning = false
  private var lastTxBytes = 0L
  private var lastRxBytes = 0L

  private fun run() : List<Long>{
    val txBytes = TrafficStats.getTotalTxBytes() - lastTxBytes
    val rxBytes = TrafficStats.getTotalRxBytes() - lastRxBytes
    lastTxBytes = TrafficStats.getTotalTxBytes()
    lastRxBytes = TrafficStats.getTotalRxBytes()
    return listOf(rxBytes / 1024, txBytes / 1024)
  }

  @TargetApi(Build.VERSION_CODES.S)
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "perf_view")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    uid = android.os.Process.myUid()
    lastTxBytes = TrafficStats.getTotalTxBytes()
    lastRxBytes = TrafficStats.getTotalRxBytes()
  }

  @TargetApi(Build.VERSION_CODES.S)
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getNetworkInfo" -> {
        result.success(run())
      }
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getMemoryInfo" -> {
        val totalMemory: Long = getTotalRam() / 1048576L
        val available: Long = getAvaiableRam() / 1048576L
        result.success(listOf<Long>(totalMemory, available))
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun getTotalRam(): Long {
    val actManager =
      context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val memInfo = ActivityManager.MemoryInfo()
    assert(actManager != null)
    actManager.getMemoryInfo(memInfo)
    return memInfo.totalMem
  }

  private fun getAvaiableRam(): Long {
    val actManager =
      context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val memInfo = ActivityManager.MemoryInfo()
    assert(actManager != null)
    actManager.getMemoryInfo(memInfo)
    return memInfo.availMem - memInfo.threshold
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
