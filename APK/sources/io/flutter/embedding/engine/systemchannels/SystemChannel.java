package io.flutter.embedding.engine.systemchannels;

import androidx.media3.exoplayer.rtsp.SessionDescription;
import io.flutter.Log;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import java.util.HashMap;

/* JADX INFO: loaded from: classes3.dex */
public class SystemChannel {
    private static final String TAG = "SystemChannel";
    public final BasicMessageChannel<Object> channel;

    public SystemChannel(DartExecutor dartExecutor) {
        this.channel = new BasicMessageChannel<>(dartExecutor, "flutter/system", JSONMessageCodec.INSTANCE);
    }

    public void sendMemoryPressureWarning() {
        Log.v(TAG, "Sending memory pressure warning to Flutter.");
        HashMap map = new HashMap(1);
        map.put(SessionDescription.ATTR_TYPE, "memoryPressure");
        this.channel.send(map);
    }
}
