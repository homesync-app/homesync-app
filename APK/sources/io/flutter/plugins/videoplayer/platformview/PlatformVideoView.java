package io.flutter.plugins.videoplayer.platformview;

import android.content.Context;
import android.os.Build;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;

/* JADX INFO: loaded from: classes4.dex */
public final class PlatformVideoView implements PlatformView {
    private final SurfaceView surfaceView;

    public PlatformVideoView(Context context, ExoPlayer exoPlayer) {
        SurfaceView surfaceView = new SurfaceView(context);
        this.surfaceView = surfaceView;
        if (Build.VERSION.SDK_INT == 28) {
            setupSurfaceWithCallback(exoPlayer);
            return;
        }
        if (Build.VERSION.SDK_INT <= 25) {
            surfaceView.setZOrderMediaOverlay(true);
        }
        exoPlayer.setVideoSurfaceView(surfaceView);
    }

    private void setupSurfaceWithCallback(final ExoPlayer exoPlayer) {
        this.surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() { // from class: io.flutter.plugins.videoplayer.platformview.PlatformVideoView.1
            @Override // android.view.SurfaceHolder.Callback
            public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i2, int i3) {
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceCreated(SurfaceHolder surfaceHolder) {
                exoPlayer.setVideoSurface(surfaceHolder.getSurface());
                exoPlayer.seekTo(1L);
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
                exoPlayer.setVideoSurface(null);
            }
        });
    }

    @Override // io.flutter.plugin.platform.PlatformView
    public View getView() {
        return this.surfaceView;
    }

    @Override // io.flutter.plugin.platform.PlatformView
    public void dispose() {
        this.surfaceView.getHolder().getSurface().release();
    }
}
