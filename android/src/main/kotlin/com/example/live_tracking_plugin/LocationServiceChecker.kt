package com.example.live_tracking_plugin

import android.content.Context
import android.location.LocationManager
import android.os.Build

object LocationServiceChecker {
    fun isLocationServiceEnabled(context: Context?): Boolean {
        if (context == null) return false

        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            locationManager?.isLocationEnabled ?: false
        } else {
            val gpsEnabled = locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) ?: false
            val networkEnabled =
                locationManager?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) ?: false
            gpsEnabled || networkEnabled
        }
    }

    fun isGPSEnabled(context: Context?): Boolean {
        if (context == null) return false

        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        return locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) ?: false
    }

    fun isNetworkLocationEnabled(context: Context?): Boolean {
        if (context == null) return false

        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        return locationManager?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) ?: false
    }
}
