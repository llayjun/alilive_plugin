package com.example.alilive_plugin.live;

import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.widget.Toast;

import com.example.alilive_plugin.AlilivePlugin;

public class ToastUtils {

    public static void show(final String content) {
        if (!TextUtils.isEmpty(content)) {
            new Handler(Looper.getMainLooper()).post(new Runnable() {

                @Override
                public void run() {
                    Toast.makeText(AlilivePlugin.context, content, Toast.LENGTH_SHORT).show();
                }
            });
        }
    }

}
