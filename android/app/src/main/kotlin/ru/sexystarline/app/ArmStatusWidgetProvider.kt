package ru.sexystarline.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Night Drive home-screen widget: arm status + deep-link CTA into the app.
 *
 * Data is pushed from Flutter via home_widget SharedPreferences — this provider
 * does not call StarLine / network (API budget).
 */
class ArmStatusWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.arm_status_widget).apply {
        val deviceName =
            widgetData.getString(KEY_DEVICE_NAME, null)
                ?: context.getString(R.string.widget_default_title)
        val status =
            widgetData.getString(KEY_STATUS_LABEL, null)
                ?: context.getString(R.string.widget_default_status)
        val subtitle =
            widgetData.getString(KEY_SUBTITLE, null)
                ?: context.getString(R.string.widget_default_subtitle)
        val actionLabel =
            widgetData.getString(KEY_ACTION_LABEL, null)
                ?: context.getString(R.string.widget_open)
        val armed = widgetData.getBoolean(KEY_ARMED, false)
        val online = widgetData.getBoolean(KEY_ONLINE, false)
        val hasSession = widgetData.getBoolean(KEY_HAS_SESSION, false)

        setTextViewText(R.id.widget_brand, context.getString(R.string.widget_brand))
        setTextViewText(R.id.widget_device_name, deviceName)
        setTextViewText(R.id.widget_status, status)
        setTextViewText(R.id.widget_subtitle, subtitle)
        setTextViewText(R.id.widget_action_button, actionLabel)

        val accent =
            if (armed && online) {
              context.getColor(R.color.night_drive_cyan)
            } else if (!online) {
              context.getColor(R.color.night_drive_danger)
            } else {
              context.getColor(R.color.night_drive_amber)
            }
        setTextColor(R.id.widget_status, accent)

        // Body → open app
        val openIntent =
            HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse(URI_OPEN),
            )
        setOnClickPendingIntent(R.id.widget_root, openIntent)

        // Primary CTA — arm / disarm / open (always deep-links into app)
        val actionUri =
            when {
              !hasSession || !online -> URI_OPEN
              armed -> URI_DISARM
              else -> URI_ARM
            }
        val actionIntent =
            HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse(actionUri),
            )
        setOnClickPendingIntent(R.id.widget_action_button, actionIntent)

        // Secondary shortcuts when session + online
        if (hasSession && online) {
          setViewVisibility(R.id.widget_secondary_row, View.VISIBLE)
          val armIntent =
              HomeWidgetLaunchIntent.getActivity(
                  context,
                  MainActivity::class.java,
                  Uri.parse(URI_ARM),
              )
          val disarmIntent =
              HomeWidgetLaunchIntent.getActivity(
                  context,
                  MainActivity::class.java,
                  Uri.parse(URI_DISARM),
              )
          setOnClickPendingIntent(R.id.widget_arm_button, armIntent)
          setOnClickPendingIntent(R.id.widget_disarm_button, disarmIntent)
        } else {
          setViewVisibility(R.id.widget_secondary_row, View.GONE)
        }
      }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  companion object {
    private const val KEY_DEVICE_NAME = "device_name"
    private const val KEY_STATUS_LABEL = "status_label"
    private const val KEY_SUBTITLE = "subtitle"
    private const val KEY_ACTION_LABEL = "action_label"
    private const val KEY_ARMED = "armed"
    private const val KEY_ONLINE = "online"
    private const val KEY_HAS_SESSION = "has_session"

    private const val URI_OPEN = "sexystarline://widget/open"
    private const val URI_ARM = "sexystarline://widget/arm"
    private const val URI_DISARM = "sexystarline://widget/disarm"
  }
}
