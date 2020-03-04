package com.example.alilive_plugin.boast;

import android.content.Intent;
import android.os.Bundle;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.example.alilive_plugin.R;
import com.pili.pldroid.player.AVOptions;
import com.pili.pldroid.player.PLMediaPlayer;

import java.io.IOException;

public class PlayActivity extends AppCompatActivity {

    public static final String LIVE_URL_KEY = "LIVE_URL_KEY";

    private PLMediaPlayer mMediaPlayer;
    SurfaceView surfaceView;
    private AVOptions mAVOptions;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.play_activity);
        Intent intent = getIntent();
        final String url = intent.getStringExtra(LIVE_URL_KEY);
        surfaceView = findViewById(R.id.surface_view);
        mAVOptions = new AVOptions();
        mAVOptions.setInteger(AVOptions.KEY_PREPARE_TIMEOUT, 10 * 1000);
        mMediaPlayer = new PLMediaPlayer(this, mAVOptions);
        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                try {
                    mMediaPlayer.setDisplay(surfaceView.getHolder());
                    mMediaPlayer.setDataSource(url);
                    mMediaPlayer.prepareAsync();
                    mMediaPlayer.start();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
            }
            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
            }
        });


    }
}
