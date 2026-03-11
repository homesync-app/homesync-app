package androidx.media3.common.audio;

import android.media.AudioManager;

/* JADX INFO: compiled from: D8$$SyntheticClass */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class AudioFocusManager$$ExternalSyntheticLambda0 implements AudioManager.OnAudioFocusChangeListener {
    public final /* synthetic */ AudioFocusManager f$0;

    public /* synthetic */ AudioFocusManager$$ExternalSyntheticLambda0(AudioFocusManager audioFocusManager) {
        this.f$0 = audioFocusManager;
    }

    @Override // android.media.AudioManager.OnAudioFocusChangeListener
    public final void onAudioFocusChange(int i) {
        this.f$0.handlePlatformAudioFocusChange(i);
    }
}
