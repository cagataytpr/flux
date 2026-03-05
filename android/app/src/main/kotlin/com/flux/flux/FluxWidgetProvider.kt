package com.flux.flux

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class FluxWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                
                val totalBalance = widgetData.getString("total_balance", "0.0")
                val monthSpent = widgetData.getString("month_spent", "0.0")
                val monthRemaining = widgetData.getString("month_remaining", "0.0")
                
                setTextViewText(R.id.tv_total_balance, totalBalance)
                setTextViewText(R.id.tv_month_spent, monthSpent)
                setTextViewText(R.id.tv_month_remaining, monthRemaining)
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
