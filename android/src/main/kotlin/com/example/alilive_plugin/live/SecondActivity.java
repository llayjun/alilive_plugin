package com.example.alilive_plugin.live;

import android.Manifest;
import android.app.ListActivity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.ListView;
import android.widget.Switch;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.PermissionChecker;

import com.alivc.live.pusher.AlivcLivePusher;
import com.example.alilive_plugin.R;
import com.example.alilive_plugin.live.auth.PushAuth;

public class SecondActivity extends ListActivity {

    public static final String LIVE_URL_KEY = "LIVE_URL_KEY";

    private String[] mModules = null;
    private Switch mEnableDebug;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.second_main);
        Intent intent = getIntent();
        String url = intent.getStringExtra(LIVE_URL_KEY);
        if (!TextUtils.isEmpty(url)){
            PushAuth.setAuthUrl(url);
        }
        mModules = new String[]{
                getString(R.string.live_normal_function),
                getString(R.string.video_recording),
                "地址" + (TextUtils.isEmpty(url) ? " " : url)
        };
        if(Build.VERSION.SDK_INT < 21)
        {
            mModules = null;
            mModules = new String[]{
                    getString(R.string.live_basic_function),
            };
        }
        setListAdapter(new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, mModules));

        mEnableDebug = (Switch) findViewById(R.id.enable_debug_view);
        mEnableDebug.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    AlivcLivePusher.showDebugView(getApplicationContext());
                } else {
                    AlivcLivePusher.hideDebugView(getApplicationContext());
                }
            }
        });
        if (!permissionCheck()) {
            if (Build.VERSION.SDK_INT >= 23) {
                ActivityCompat.requestPermissions(this, permissionManifest, PERMISSION_REQUEST_CODE);
            } else {
                showNoPermissionTip(getString(noPermissionTip[mNoPermissionIndex]));
                finish();
            }
        }
    }

    public void onListItemClick(ListView parent, View v, int position, long id) {
        Intent intent;
        switch (position) {
            case 0:
                intent = new Intent(this, PushConfigActivity.class);
                startActivity(intent);
                break;
            case 1:
                intent = new Intent(this, VideoRecordConfigActivity.class);
                startActivity(intent);
                break;
            default:
                break;
        }
    }

    private int mNoPermissionIndex = 0;
    private final int PERMISSION_REQUEST_CODE = 1;
    private final String[] permissionManifest = {
            Manifest.permission.CAMERA,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE
    };

    private final int[] noPermissionTip = {
            R.string.no_camera_permission,
            R.string.no_record_bluetooth_permission,
            R.string.no_record_audio_permission,
            R.string.no_read_phone_state_permission,
            R.string.no_write_external_storage_permission,
            R.string.no_read_external_storage_permission,
    };

    private boolean permissionCheck() {
        int permissionCheck = PackageManager.PERMISSION_GRANTED;
        String permission;
        for (int i = 0; i < permissionManifest.length; i++) {
            permission = permissionManifest[i];
            mNoPermissionIndex = i;
            if (PermissionChecker.checkSelfPermission(this, permission)
                    != PackageManager.PERMISSION_GRANTED) {
                permissionCheck = PackageManager.PERMISSION_DENIED;
            }
        }
        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            return false;
        } else {
            return true;
        }
    }

    private void showNoPermissionTip(String tip) {
        Toast.makeText(this, tip, Toast.LENGTH_LONG).show();
    }

}
