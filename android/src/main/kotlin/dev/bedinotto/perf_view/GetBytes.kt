//package dev.bedinotto.perf_view
//
//import android.annotation.TargetApi
//import android.app.usage.NetworkStatsManager
//import android.content.Context
//import android.content.pm.PackageManager
//import android.net.ConnectivityManager
//import android.net.NetworkCapabilities
//import android.net.NetworkStats
//import android.net.NetworkStatsManager
//import android.os.Build
//import androidx.annotation.RequiresApi
//
//@TargetApi(Build.VERSION_CODES.M)
//fun getNetworkUsageForApp(context: Context, packageName: String): Long {
//    val networkStatsManager = context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
//    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
//    val allNetworks = connectivityManager.allNetworks
//
//    val uid = android.os.Process.myUid()
//    val startTime = System.currentTimeMillis() - 3 * 1000 // Get stats for the last 10 minutes
//    val endTime = System.currentTimeMillis()
//
//    var totalNetworkUsage = 0L
//    for (network in allNetworks) {
//        val networkCapabilities = connectivityManager.getNetworkCapabilities(network)
//        if (networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true ||
//            networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true) {
//            val networkStats = networkStatsManager.queryDetailsForUid(network, startTime, endTime, uid)
//            totalNetworkUsage += networkStats + networkStats.txBytes
//        }
//    }
//
//    return totalNetworkUsage
//}
//
////fun getNetworkUsageForApp(context: Context, packageName: String): Long {
////    val networkStatsManager = context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
////    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
////    val activeNetwork = connectivityManager.activeNetwork ?: return 0L
////
////    val uid = getUid(context, packageName)
////    val startTime = System.currentTimeMillis() - 10 * 60 * 1000 // Get stats for the last 10 minutes
////    val endTime = System.currentTimeMillis()
////
////    val networkStats = networkStatsManager.querySummary(activeNetwork, uid, startTime, endTime)
////    return networkStats.rxBytes + networkStats.txBytes
////}
////
////private fun getUid(context: Context, packageName: String): Int {
////    val packageManager = context.packageManager
////    val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_META_DATA)
////    return packageInfo.uid
////}
////
////class GetBytes {
////
////}