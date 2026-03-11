package androidx.media3.exoplayer.audio;

import android.media.AudioDeviceInfo;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.exoplayer.analytics.PlayerId;
import androidx.media3.exoplayer.audio.AudioOutput;
import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes.dex */
public class ForwardingAudioOutput implements AudioOutput {
    private final AudioOutput audioOutput;

    public ForwardingAudioOutput(AudioOutput audioOutput) {
        this.audioOutput = audioOutput;
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void addListener(AudioOutput.Listener listener) {
        this.audioOutput.addListener(listener);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void play() {
        this.audioOutput.play();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void pause() {
        this.audioOutput.pause();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public boolean write(ByteBuffer byteBuffer, int i, long j) throws AudioOutput.WriteException {
        return this.audioOutput.write(byteBuffer, i, j);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void flush() {
        this.audioOutput.flush();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void stop() {
        this.audioOutput.stop();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void release() {
        this.audioOutput.release();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void setVolume(float f) {
        this.audioOutput.setVolume(f);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public boolean isOffloadedPlayback() {
        return this.audioOutput.isOffloadedPlayback();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public int getAudioSessionId() {
        return this.audioOutput.getAudioSessionId();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public int getSampleRate() {
        return this.audioOutput.getSampleRate();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public long getBufferSizeInFrames() {
        return this.audioOutput.getBufferSizeInFrames();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public long getPositionUs() {
        return this.audioOutput.getPositionUs();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public PlaybackParameters getPlaybackParameters() {
        return this.audioOutput.getPlaybackParameters();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public boolean isStalled() {
        return this.audioOutput.isStalled();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void removeListener(AudioOutput.Listener listener) {
        this.audioOutput.removeListener(listener);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void setPlaybackParameters(PlaybackParameters playbackParameters) {
        this.audioOutput.setPlaybackParameters(playbackParameters);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void setOffloadDelayPadding(int i, int i2) {
        this.audioOutput.setOffloadDelayPadding(i, i2);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void setOffloadEndOfStream() {
        this.audioOutput.setOffloadEndOfStream();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void setPlayerId(PlayerId playerId) {
        this.audioOutput.setPlayerId(playerId);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void attachAuxEffect(int i) {
        this.audioOutput.attachAuxEffect(i);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void setAuxEffectSendLevel(float f) {
        this.audioOutput.setAuxEffectSendLevel(f);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutput
    public void setPreferredDevice(AudioDeviceInfo audioDeviceInfo) {
        this.audioOutput.setPreferredDevice(audioDeviceInfo);
    }
}
