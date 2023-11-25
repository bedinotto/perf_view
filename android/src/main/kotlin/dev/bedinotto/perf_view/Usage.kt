package dev.bedinotto.perf_view

import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.Context.NETWORK_STATS_SERVICE
import android.net.ConnectivityManager
import android.os.Build
import android.os.RemoteException


class Usage {
    var totalRxBytes: Long = 0 //Total data download bytes
    var totalTxBytes: Long = 0 //Total data upload bytes
    var wifiTotalData: Long = 0 //wifi total traffic data
    var mobileTotalData: Long = 0 //Mobile total traffic data
    var mobileRxBytes: Long = 0 //Mobile download bytes
    var mobileTxBytes: Long = 0 //Mobile upload byte
    var wifiRxBytes: Long = 0 //wifi download bytes
    var wifiTxBytes: Long = 0 //wifi upload bytes
    var uid: String? = null //Package name
}

/**
 * Get uid (single) application traffic
 *
 * @param context   context
 * @param startTime start time
 * @param endTime   End time
 * @param uid       Application uid
 * @return
 */
fun getUsageBytesByUid(context: Context, startTime: Long, endTime: Long, uid: Int): Usage? {
    val usage = Usage()
    usage.totalRxBytes = 0
    usage.totalTxBytes = 0
    usage.mobileRxBytes = 0
    usage.mobileTxBytes = 0
    usage.wifiTxBytes = 0
    usage.wifiTxBytes = 0
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        val nsm = (context.getSystemService(NETWORK_STATS_SERVICE) as NetworkStatsManager)
        val wifi =
            nsm.queryDetailsForUid(ConnectivityManager.TYPE_WIFI, null, startTime, endTime, uid)
        val moble =
            nsm.queryDetailsForUid(ConnectivityManager.TYPE_MOBILE, null, startTime, endTime, uid)
        do {
            val bucket = NetworkStats.Bucket()
            if (wifi.getNextBucket(bucket)) {
                usage.wifiRxBytes += bucket.rxBytes
                usage.wifiTxBytes += bucket.txBytes
            }
        } while (wifi.hasNextBucket())

        do {
            val bucket = NetworkStats.Bucket()
            if (moble.getNextBucket(bucket)) {
                usage.mobileRxBytes += bucket.rxBytes
                usage.mobileTxBytes += bucket.txBytes
            }
        } while (moble.hasNextBucket())
//        do {
//            val bucket = NetworkStats.Bucket()
//            wifi.getNextBucket(bucket)
//            usage.wifiRxBytes += bucket.rxBytes
//            usage.wifiTxBytes += bucket.txBytes
//        } while (wifi.hasNextBucket())
//        do {
//            val bucket = NetworkStats.Bucket()
//            moble.getNextBucket(bucket)
//            usage.mobileRxBytes += bucket.rxBytes
//            usage.mobileTxBytes += bucket.txBytes
//        } while (moble.hasNextBucket())
        usage.wifiTotalData = usage.wifiRxBytes + usage.wifiTxBytes
        usage.mobileTotalData = usage.mobileRxBytes + usage.mobileTxBytes
        wifi.close()
        moble.close()
    }

    return usage
}

/**
 * Get single application traffic
 * @param context    context
 * @param startTime  start time
 * @param endTime    End time
 * @param uid        Statistical application uid
 * @return
 */
fun getApplicationQuerySummary(context: Context, startTime: Long, endTime: Long, uid: Int): Usage? {
    var usage = Usage()
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        val nsm = (context.getSystemService(NETWORK_STATS_SERVICE) as NetworkStatsManager)
        try {
            val wifi = nsm.querySummary(ConnectivityManager.TYPE_WIFI, null, startTime, endTime)
            val mobile = nsm.querySummary(ConnectivityManager.TYPE_MOBILE, null, startTime, endTime)
            do {
                val bucket = NetworkStats.Bucket()
                wifi.getNextBucket(bucket)
                if (bucket.uid == uid) {
                    usage.wifiRxBytes += bucket.rxBytes
                    usage.wifiTxBytes += bucket.txBytes
                }
            } while (wifi.hasNextBucket())
            do {
                val bucket = NetworkStats.Bucket()
                mobile.getNextBucket(bucket)
                if (bucket.uid == uid) {
                    usage.mobileRxBytes += bucket.rxBytes
                    usage.mobileTxBytes += bucket.txBytes
                }
            } while (mobile.hasNextBucket())
            usage.wifiTotalData = usage.wifiRxBytes + usage.wifiTxBytes
            usage.mobileTotalData = usage.mobileRxBytes + usage.mobileTxBytes
        } catch (e: RemoteException) {
            e.printStackTrace()
        }
    }
    return usage
}

/**
 * Get single application traffic
 * @param context
 * @param startTime
 * @param endTime
 * @param uid
 * @return
 */
fun getApplicationQueryDetails(context: Context, startTime: Long, endTime: Long, uid: Int): Usage? {
    var usage = Usage()
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        val nsm = (context.getSystemService(NETWORK_STATS_SERVICE) as NetworkStatsManager)
        try {
            val wifi = nsm.queryDetails(ConnectivityManager.TYPE_WIFI, null, startTime, endTime)
            val mobile = nsm.queryDetails(ConnectivityManager.TYPE_MOBILE, null, startTime, endTime)
            do {
                val bucket = NetworkStats.Bucket()
                wifi.getNextBucket(bucket)
                if (bucket.uid == uid) {
                    usage.wifiRxBytes += bucket.rxBytes
                    usage.wifiTxBytes += bucket.txBytes
                }
            } while (wifi.hasNextBucket())
            do {
                val bucket = NetworkStats.Bucket()
                mobile.getNextBucket(bucket)
                if (bucket.uid == uid) {
                    usage.mobileRxBytes += bucket.rxBytes
                    usage.mobileTxBytes += bucket.txBytes
                }
            } while (mobile.hasNextBucket())
            usage.wifiTotalData = usage.wifiRxBytes + usage.wifiTxBytes
            usage.mobileTotalData = usage.mobileRxBytes + usage.mobileTxBytes
        } catch (e: RemoteException) {
            e.printStackTrace()
        }
    }
    return usage
}