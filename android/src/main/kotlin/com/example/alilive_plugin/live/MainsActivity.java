package com.example.alilive_plugin.live;

import android.Manifest;
import android.app.ListActivity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.PermissionChecker;

import com.example.alilive_plugin.R;

public class MainsActivity extends ListActivity {


    String[] modules = null;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //首次安装按home键置入后台，从桌面图标点击重新启动的问题
        if (!isTaskRoot()) {
            finish();
            return;
        }

        setContentView(R.layout.activity_main);
        modules = new String[]{
                getString(R.string.live_basic_function),
                getString(R.string.license_declaration)
        };
        setListAdapter(new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, modules));

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
                intent = new Intent(this, SecondActivity.class);
                startActivity(intent);
                break;
            case 1:
                intent = new Intent(this, LicenseActivity.class);
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
