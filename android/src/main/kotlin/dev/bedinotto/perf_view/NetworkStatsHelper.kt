package dev.bedinotto.perf_view

import android.annotation.TargetApi
import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.RemoteException
import android.telephony.TelephonyManager

@TargetApi(Build.VERSION_CODES.P)
class NetworkStatsHelper {
    private var networkStatsManager: NetworkStatsManager
    private var packageUid = 0

    constructor(networkStatsManager: NetworkStatsManager) {
        this.networkStatsManager = networkStatsManager
    }

    constructor(networkStatsManager: NetworkStatsManager, packageUid: Int) {
        this.networkStatsManager = networkStatsManager
        this.packageUid = packageUid
    }

    fun getAllRxBytesMobile(context: Context): Long {
        val bucket: NetworkStats.Bucket = try {
            networkStatsManager.querySummaryForDevice(
                0,
                getSubscriberId(context, 0),
                0,
                System.currentTimeMillis()
            )
        } catch (e: RemoteException) {
            return -1
        }
        return bucket.rxBytes
    }

    fun getAllTxBytesMobile(context: Context): Long {
        val bucket: NetworkStats.Bucket = try {
            networkStatsManager.querySummaryForDevice(
                0,
                getSubscriberId(context, 0),
                0,
                System.currentTimeMillis()
            )
        } catch (e: RemoteException) {
            return -1
        }
        return bucket.txBytes
    }

    val allRxBytesWifi: Long
        get() {
            val bucket: NetworkStats.Bucket = try {
                networkStatsManager.querySummaryForDevice(
                    1,
                    "",
                    0,
                    System.currentTimeMillis()
                )
            } catch (e: RemoteException) {
                return -1
            }
            return bucket.rxBytes
        }
    val allTxBytesWifi: Long
        get() {
            val bucket: NetworkStats.Bucket = try {
                networkStatsManager.querySummaryForDevice(
                    1,
                    "",
                    0,
                    System.currentTimeMillis()
                )
            } catch (e: RemoteException) {
                return -1
            }
            return bucket.txBytes
        }

    fun getPackageRxBytesMobile(context: Context): Long {
        val networkStats: NetworkStats? = try {
            networkStatsManager.queryDetailsForUid(
                0,
                getSubscriberId(context, 0),
                0,
                System.currentTimeMillis(),
                packageUid
            )
        } catch (e: RemoteException) {
            return -1
        }
        var rxBytes = 0L
        val bucket = NetworkStats.Bucket()
        if (networkStats != null) {
            while (networkStats.hasNextBucket()) {
                networkStats.getNextBucket(bucket)
                rxBytes += bucket.rxBytes
            }
        }
        networkStats?.close()
        return rxBytes
    }

    fun getPackageTxBytesMobile(context: Context): Long {
        val networkStats: NetworkStats? = try {
            networkStatsManager.queryDetailsForUid(
                0,
                getSubscriberId(context, 0),
                0,
                System.currentTimeMillis(),
                packageUid
            )
        } catch (e: RemoteException) {
            return -1
        }
        var txBytes = 0L
        val bucket = NetworkStats.Bucket()
        if (networkStats != null) {
            while (networkStats.hasNextBucket()) {
                networkStats.getNextBucket(bucket)
                txBytes += bucket.txBytes
            }
        }
        networkStats?.close()
        return txBytes
    }

    val packageRxBytesWifi: Long
        get() {
            val networkStats: NetworkStats? = try {
                networkStatsManager.queryDetailsForUid(
                    1,
                    "",
                    0,
                    System.currentTimeMillis(),
                    packageUid
                )
            } catch (e: RemoteException) {
                return -1
            }
            var rxBytes = 0L
            val bucket = NetworkStats.Bucket()
            if (networkStats != null) {
                while (networkStats.hasNextBucket()) {
                    networkStats.getNextBucket(bucket)
                    rxBytes += bucket.rxBytes
                }
            }
            networkStats?.close()
            return rxBytes
        }
    val packageTxBytesWifi: Long
        get() {
            val networkStats: NetworkStats? = try {
                networkStatsManager.queryDetailsForUid(
                    1,
                    "",
                    0,
                    System.currentTimeMillis(),
                    packageUid
                )
            } catch (e: RemoteException) {
                return -1
            }
            var txBytes = 0L
            val bucket = NetworkStats.Bucket()
            if (networkStats != null) {
                while (networkStats.hasNextBucket()) {
                    networkStats.getNextBucket(bucket)
                    txBytes += bucket.txBytes
                }
            }
            networkStats?.close()
            return txBytes
        }

    private fun getSubscriberId(context: Context, networkType: Int): String {
        if (0 == networkType) {
            val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            return tm.subscriberId
        }
        return ""
    }
}