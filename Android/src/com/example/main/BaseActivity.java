package com.example.main;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;

import com.examples.common.PermissionManager;

public class BaseActivity extends Activity {

    private static boolean mHasRequested = false;

    protected Handler mainhandler = new Handler();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        if (!PermissionManager.getInstance().checkPermission(PermissionManager.VIDEO_PERMISSION)) {
            PermissionManager.getInstance().applySDKPermissions(this);
        } else {
            mainhandler.post(new Runnable() {
                @Override
                public void run() {
                    onRequestPermissionsFinished();
                }
            });
        }
		DemoApp.getInstance().onActivityCreate(this);
	}
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        mHasRequested = true;
        onRequestPermissionsFinished();
    }
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		DemoApp.getInstance().onActivityDestroy(this);
	}
    protected void onRequestPermissionsFinished() {
        DemoApp.getInstance().initCloudroomVideoSDK();
    }
}
