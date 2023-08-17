package com.examples.tool;

import java.text.SimpleDateFormat;
import java.util.Date;

import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.content.ContentUris;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.database.Cursor;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.util.Log;

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


	public static int dip2px(Context context, float dpValue) {
		float scale = context.getResources().getDisplayMetrics().density;
		return (int) (dpValue * scale + 0.5f);
	}

	public static int px2dip(Context context, float pxValue) {
		final float scale = context.getResources().getDisplayMetrics().density;
		return (int) (pxValue / scale + 0.5f);

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

	public static String LoadString(Context context, String resName) {
		if (context == null) {
			Log.w("Tools", "LoadString context is null");
		}
		String str = "";
		int strId = getResourceId(context, "string", resName);
		if (strId > 0) {
			str = context.getResources().getString(strId);
		}
		return str;
	}


	public static int getResourceId(Context context, String resType, String resName) {
		if (context == null) {
			Log.w("Tools", "getResourceId context is null");
		}

		try {
			int sourceId = context.getResources().getIdentifier(resName, resType, context.getPackageName());
			return sourceId;
		} catch (Exception var4) {
			var4.printStackTrace();
			return 0;
		}
	}

	public static int getResourceId(Context context, String resClassAndName) {
		if (context == null) {
			Log.w("Tools", "getResourceId context is null");
		}

		try {
			String[] strs = resClassAndName.split("\\.");
			if (strs.length == 3) {
				String resType = strs[1];
				String resName = strs[2];
				return getResourceId(context, resType, resName);
			}
		} catch (Exception var5) {
		}

		return 0;
	}

	public static String toHexEncoding(int color) {
		String R, G, B, A;
		StringBuffer sb = new StringBuffer();
		R = Integer.toHexString(Color.red(color)).toUpperCase();
		G = Integer.toHexString(Color.green(color)).toUpperCase();
		B = Integer.toHexString(Color.blue(color)).toUpperCase();
		A = Integer.toHexString(Color.alpha(color)).toUpperCase();
		R = R.length() == 1 ? "0" + R : R;
		G = G.length() == 1 ? "0" + G : G;
		B = B.length() == 1 ? "0" + B : B;
		A = A.length() == 1 ? "0" + A : A;
		sb.append("#");
		sb.append(R);
		sb.append(G);
		sb.append(B);
		sb.append(A);
		return sb.toString();
	}
}
