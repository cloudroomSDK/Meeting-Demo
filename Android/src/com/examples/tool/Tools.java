package com.examples.tool;

import java.text.SimpleDateFormat;
import java.util.Date;

import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.content.ContentUris;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.DocumentsContract;
import android.provider.MediaStore;

@SuppressLint("SimpleDateFormat")
public class Tools {

	public static String getTimeStr(int sec) {
		int s = sec % 60;
		int m = sec / 60;
		int h = m / 60;
		StringBuffer time = new StringBuffer();
		if (h > 0) {
			time.append(h).append("小时");
		}
		if (m > 0) {
			time.append(m).append("分");
		}
		time.append(s).append("秒");
		return time.toString();
	}

	public static boolean detectOpenGLES20(Context context) {
		ActivityManager am = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		ConfigurationInfo info = am.getDeviceConfigurationInfo();
		return (info.reqGlEsVersion >= 0x20000);
	}

	/**
	 * sp转换成px
	 */
	public static int sp2px(Context context, float spValue) {
		float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
		return (int) (spValue * fontScale + 0.5f);
	}

	@SuppressLint("NewApi")
	public static String getUriFilePath(Context context, Uri uri) {
		String path = null;
		if (Build.VERSION.SDK_INT >= 19
				&& DocumentsContract.isDocumentUri(context, uri)) {
			// 如果是document类型的Uri，则通过document id处理
			String docId = DocumentsContract.getDocumentId(uri);
			if ("com.android.providers.media.documents".equals(uri
					.getAuthority())) {
				String id = docId.split(":")[1]; // 解析出数字格式的id
				String selection = MediaStore.Images.Media._ID + "=" + id;
				path = getPathFromUri(context,
						MediaStore.Images.Media.EXTERNAL_CONTENT_URI, selection);
			} else if ("com.android.providers.downloads.documents".equals(uri
					.getAuthority())) {
				Uri contentUri = ContentUris.withAppendedId(
						Uri.parse("content://downloads/public_downloads"),
						Long.valueOf(docId));
				path = getPathFromUri(context, contentUri, null);
			}
		} else if ("content".equalsIgnoreCase(uri.getScheme())) {
			// 如果是content类型的Uri，则使用普通方式处理
			path = getPathFromUri(context, uri, null);
		} else if ("file".equalsIgnoreCase(uri.getScheme())) {
			// 如果是file类型的Uri，直接获取图片路径即可
			path = uri.getPath();
		}
		return path;
	}

	private static String getPathFromUri(Context act, Uri uri, String selection) {
		String path = null;
		String[] projection = { MediaStore.Images.Media.DATA };
		Cursor cursor = act.getContentResolver().query(uri, projection,
				selection, null, null);
		if (cursor != null) {
			if (cursor.moveToFirst()) {
				path = cursor.getString(cursor
						.getColumnIndex(MediaStore.Images.Media.DATA));
			}
			cursor.close();
		}
		return path;
	}

	// 时间格式化对象
	private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat(
			"yyyy-MM-DD HH:mm:ss.SSS");

	public static String getCurrentTimeStr() {
		Date date = new Date(System.currentTimeMillis());
		return DATE_FORMAT.format(date);
	}
}
