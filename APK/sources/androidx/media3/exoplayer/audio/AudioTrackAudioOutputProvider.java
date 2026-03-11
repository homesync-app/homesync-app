package androidx.media3.exoplayer.audio;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioDeviceInfo;
import android.media.AudioFormat;
import android.media.AudioTrack;
import android.os.Build;
import android.os.Looper;
import android.util.Pair;
import androidx.media3.common.Format;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.util.Clock;
import androidx.media3.common.util.ListenerSet;
import androidx.media3.common.util.Log;
import androidx.media3.common.util.Util;
import androidx.media3.exoplayer.audio.AudioCapabilitiesReceiver;
import androidx.media3.exoplayer.audio.AudioOutputProvider;
import androidx.media3.exoplayer.audio.AudioSink;
import androidx.media3.exoplayer.audio.AudioTrackAudioOutput;
import androidx.media3.exoplayer.audio.DefaultAudioSink;
import com.google.common.base.Preconditions;
import java.util.Objects;
import java.util.function.BiConsumer;
import kotlinx.serialization.json.internal.AbstractJsonLexerKt;
import org.checkerframework.checker.nullness.qual.EnsuresNonNull;
import org.checkerframework.checker.nullness.qual.RequiresNonNull;

/* JADX INFO: loaded from: classes.dex */
public final class AudioTrackAudioOutputProvider implements AudioOutputProvider {
    private static final String TAG = "ATAudioOutputProvider";
    public static boolean failOnSpuriousAudioTimestamp = false;
    private AudioCapabilities audioCapabilities;
    private AudioCapabilitiesReceiver audioCapabilitiesReceiver;
    private final DefaultAudioSink.AudioOffloadSupportProvider audioOffloadSupportProvider;
    private final DefaultAudioSink.AudioTrackBufferSizeProvider audioTrackBufferSizeProvider;
    private final DefaultAudioSink.AudioTrackProvider audioTrackProvider;
    private final BiConsumer<AudioTrack.Builder, AudioOutputProvider.OutputConfig> builderModifier;
    private final CapabilityChangeListener capabilityChangeListener;
    private Clock clock;
    private final Context context;
    private Context contextWithDeviceId;
    private ListenerSet<AudioOutputProvider.Listener> listeners;
    private Looper playbackLooper;

    public static final class Builder {
        private AudioCapabilities audioCapabilities;
        private DefaultAudioSink.AudioOffloadSupportProvider audioOffloadSupportProvider;
        private BiConsumer<AudioTrack.Builder, AudioOutputProvider.OutputConfig> audioTrackBuilderModifier;
        private DefaultAudioSink.AudioTrackProvider audioTrackProvider;
        private DefaultAudioSink.AudioTrackBufferSizeProvider bufferSizeProvider;
        private final Context context;

        public Builder(Context context) {
            this.context = context != null ? context.getApplicationContext() : null;
            this.bufferSizeProvider = DefaultAudioSink.AudioTrackBufferSizeProvider.DEFAULT;
            if (context == null) {
                this.audioCapabilities = AudioCapabilities.DEFAULT_AUDIO_CAPABILITIES;
            }
        }

        public Builder setAudioTrackBuilderModifier(BiConsumer<AudioTrack.Builder, AudioOutputProvider.OutputConfig> biConsumer) {
            this.audioTrackBuilderModifier = biConsumer;
            return this;
        }

        public Builder setAudioOffloadSupportProvider(DefaultAudioSink.AudioOffloadSupportProvider audioOffloadSupportProvider) {
            this.audioOffloadSupportProvider = audioOffloadSupportProvider;
            return this;
        }

        public Builder setAudioTrackBufferSizeProvider(DefaultAudioSink.AudioTrackBufferSizeProvider audioTrackBufferSizeProvider) {
            this.bufferSizeProvider = audioTrackBufferSizeProvider;
            return this;
        }

        Builder setAudioCapabilities(AudioCapabilities audioCapabilities) {
            if (this.context == null) {
                this.audioCapabilities = audioCapabilities;
            }
            return this;
        }

        Builder setAudioTrackProvider(DefaultAudioSink.AudioTrackProvider audioTrackProvider) {
            this.audioTrackProvider = audioTrackProvider;
            return this;
        }

        public AudioTrackAudioOutputProvider build() {
            if (this.audioOffloadSupportProvider == null) {
                this.audioOffloadSupportProvider = new DefaultAudioOffloadSupportProvider(this.context);
            }
            return new AudioTrackAudioOutputProvider(this);
        }
    }

    private AudioTrackAudioOutputProvider(Builder builder) {
        this.context = builder.context;
        this.builderModifier = builder.audioTrackBuilderModifier;
        this.audioOffloadSupportProvider = (DefaultAudioSink.AudioOffloadSupportProvider) Preconditions.checkNotNull(builder.audioOffloadSupportProvider);
        this.audioTrackBufferSizeProvider = builder.bufferSizeProvider;
        this.audioCapabilities = builder.audioCapabilities;
        this.audioTrackProvider = builder.audioTrackProvider;
        this.capabilityChangeListener = builder.context != null ? new CapabilityChangeListener() : null;
        this.clock = Clock.DEFAULT;
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutputProvider
    public AudioOutputProvider.FormatSupport getFormatSupport(AudioOutputProvider.FormatConfig formatConfig) {
        updateAudioCapabilitiesReceiver(formatConfig);
        AudioOffloadSupport audioOffloadSupport = this.audioOffloadSupportProvider.getAudioOffloadSupport(formatConfig.format, formatConfig.audioAttributes);
        return new AudioOutputProvider.FormatSupport.Builder().setFormatSupportLevel(getFormatSupportLevel(formatConfig)).setIsFormatSupportedForOffload(audioOffloadSupport.isFormatSupported).setIsGaplessSupportedForOffload(audioOffloadSupport.isGaplessSupported).setIsSpeedChangeSupportedForOffload(audioOffloadSupport.isSpeedChangeSupported).build();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutputProvider
    public AudioOutputProvider.OutputConfig getOutputConfig(AudioOutputProvider.FormatConfig formatConfig) throws AudioOutputProvider.ConfigurationException {
        int i;
        AudioOffloadSupport audioOffloadSupport;
        boolean z;
        int i2;
        int i3;
        int audioOutputChannelConfig;
        int pcmFrameSize;
        boolean z2;
        int bufferSizeInBytes;
        Format format = formatConfig.format;
        updateAudioCapabilitiesReceiver(formatConfig);
        if (Objects.equals(format.sampleMimeType, MimeTypes.AUDIO_RAW)) {
            Preconditions.checkArgument(Util.isEncodingLinearPcm(format.pcmEncoding));
            int i4 = format.pcmEncoding;
            i = format.sampleRate;
            audioOutputChannelConfig = getAudioOutputChannelConfig(format.channelCount);
            pcmFrameSize = Util.getPcmFrameSize(i4, format.channelCount);
            z = formatConfig.enablePlaybackParameters;
            i2 = i4;
            z2 = false;
            i3 = 0;
        } else {
            i = format.sampleRate;
            if (formatConfig.enableOffload) {
                audioOffloadSupport = this.audioOffloadSupportProvider.getAudioOffloadSupport(format, formatConfig.audioAttributes);
            } else {
                audioOffloadSupport = AudioOffloadSupport.DEFAULT_UNSUPPORTED;
            }
            if (formatConfig.enableOffload && audioOffloadSupport.isFormatSupported) {
                int encoding = MimeTypes.getEncoding((String) Preconditions.checkNotNull(format.sampleMimeType), format.codecs);
                int audioOutputChannelConfig2 = getAudioOutputChannelConfig(format.channelCount);
                z2 = audioOffloadSupport.isGaplessSupported;
                z = true;
                i3 = 1;
                i2 = encoding;
                audioOutputChannelConfig = audioOutputChannelConfig2;
                pcmFrameSize = -1;
            } else {
                Pair<Integer, Integer> encodingAndChannelConfigForPassthrough = this.audioCapabilities.getEncodingAndChannelConfigForPassthrough(format, formatConfig.audioAttributes);
                if (encodingAndChannelConfigForPassthrough == null) {
                    throw new AudioOutputProvider.ConfigurationException("Unable to configure passthrough for: " + format);
                }
                int iIntValue = ((Integer) encodingAndChannelConfigForPassthrough.first).intValue();
                int iIntValue2 = ((Integer) encodingAndChannelConfigForPassthrough.second).intValue();
                z = formatConfig.enablePlaybackParameters;
                i2 = iIntValue;
                i3 = 2;
                audioOutputChannelConfig = iIntValue2;
                pcmFrameSize = -1;
                z2 = false;
            }
        }
        int i5 = format.bitrate;
        if (Objects.equals(format.sampleMimeType, MimeTypes.AUDIO_DTS_EXPRESS) && i5 == -1) {
            i5 = 768000;
        }
        int i6 = i5;
        if (formatConfig.preferredBufferSize != -1) {
            bufferSizeInBytes = formatConfig.preferredBufferSize;
        } else {
            int i7 = i;
            bufferSizeInBytes = this.audioTrackBufferSizeProvider.getBufferSizeInBytes(getAudioTrackMinBufferSize(i, audioOutputChannelConfig, i2), i2, i3, pcmFrameSize != -1 ? pcmFrameSize : 1, i7, i6, z ? 8.0d : 1.0d);
            i = i7;
        }
        return new AudioOutputProvider.OutputConfig.Builder().setSampleRate(i).setChannelMask(audioOutputChannelConfig).setEncoding(i2).setBufferSize(bufferSizeInBytes).setAudioSessionId(formatConfig.audioSessionId).setAudioAttributes(formatConfig.audioAttributes).setIsOffload(i3 == 1).setIsTunneling(formatConfig.enableTunneling).setUsePlaybackParameters(z).setUseOffloadGapless(z2).setVirtualDeviceId(formatConfig.virtualDeviceId).build();
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutputProvider
    public AudioTrackAudioOutput getAudioOutput(AudioOutputProvider.OutputConfig outputConfig) throws AudioOutputProvider.InitializationException {
        Context context;
        AudioTrack audioTrackBuild;
        try {
            int i = outputConfig.audioSessionId;
            if (outputConfig.virtualDeviceId == -1 || this.context == null || Build.VERSION.SDK_INT < 34) {
                context = null;
            } else {
                Context context2 = this.contextWithDeviceId;
                if (context2 == null || context2.getDeviceId() != outputConfig.virtualDeviceId) {
                    this.contextWithDeviceId = this.context.createDeviceContext(outputConfig.virtualDeviceId);
                }
                context = this.contextWithDeviceId;
                i = 0;
            }
            if (this.audioTrackProvider != null) {
                audioTrackBuild = this.audioTrackProvider.getAudioTrack(getAudioTrackConfig(outputConfig), outputConfig.audioAttributes, i, context);
            } else {
                AudioTrack.Builder sessionId = new AudioTrack.Builder().setAudioAttributes(getAudioTrackAttributes(outputConfig.audioAttributes, outputConfig.isTunneling)).setAudioFormat(new AudioFormat.Builder().setSampleRate(outputConfig.sampleRate).setChannelMask(outputConfig.channelMask).setEncoding(outputConfig.encoding).build()).setTransferMode(1).setBufferSizeInBytes(outputConfig.bufferSize).setSessionId(i);
                if (Build.VERSION.SDK_INT >= 29) {
                    sessionId.setOffloadedPlayback(outputConfig.isOffload);
                }
                if (Build.VERSION.SDK_INT >= 34 && context != null) {
                    sessionId.setContext(context);
                }
                if (this.builderModifier != null) {
                    this.builderModifier.accept(sessionId, outputConfig);
                }
                audioTrackBuild = sessionId.build();
            }
            if (audioTrackBuild.getState() != 1) {
                try {
                    audioTrackBuild.release();
                } catch (Exception unused) {
                }
                throw new AudioOutputProvider.InitializationException();
            }
            return new AudioTrackAudioOutput(audioTrackBuild, outputConfig, this.capabilityChangeListener, this.clock);
        } catch (IllegalArgumentException | UnsupportedOperationException e) {
            throw new AudioOutputProvider.InitializationException(e);
        }
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutputProvider
    public void addListener(AudioOutputProvider.Listener listener) {
        verifySinglePlaybackLooper();
        if (this.listeners == null) {
            ListenerSet<AudioOutputProvider.Listener> listenerSet = new ListenerSet<>(Thread.currentThread());
            this.listeners = listenerSet;
            listenerSet.setThrowsWhenUsingWrongThread(false);
        }
        this.listeners.add(listener);
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutputProvider
    public void removeListener(AudioOutputProvider.Listener listener) {
        ListenerSet<AudioOutputProvider.Listener> listenerSet = this.listeners;
        if (listenerSet != null) {
            listenerSet.remove(listener);
        }
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutputProvider
    public void setClock(Clock clock) {
        this.clock = clock;
    }

    @Override // androidx.media3.exoplayer.audio.AudioOutputProvider
    public void release() {
        ListenerSet<AudioOutputProvider.Listener> listenerSet = this.listeners;
        if (listenerSet != null) {
            listenerSet.release();
        }
        AudioCapabilitiesReceiver audioCapabilitiesReceiver = this.audioCapabilitiesReceiver;
        if (audioCapabilitiesReceiver != null) {
            audioCapabilitiesReceiver.unregister();
        }
    }

    private AudioAttributes getAudioTrackAttributes(androidx.media3.common.AudioAttributes audioAttributes, boolean z) {
        if (z) {
            return getAudioTrackTunnelingAttributes();
        }
        return audioAttributes.getPlatformAudioAttributes();
    }

    private AudioAttributes getAudioTrackTunnelingAttributes() {
        return new AudioAttributes.Builder().setContentType(3).setFlags(16).setUsage(1).build();
    }

    void onAudioCapabilitiesChanged(AudioCapabilities audioCapabilities) {
        verifySinglePlaybackLooper();
        AudioCapabilities audioCapabilities2 = this.audioCapabilities;
        if (audioCapabilities2 == null || audioCapabilities.equals(audioCapabilities2)) {
            return;
        }
        this.audioCapabilities = audioCapabilities;
        ListenerSet<AudioOutputProvider.Listener> listenerSet = this.listeners;
        if (listenerSet != null) {
            listenerSet.sendEvent(new ListenerSet.Event() { // from class: androidx.media3.exoplayer.audio.AudioTrackAudioOutputProvider$$ExternalSyntheticLambda1
                @Override // androidx.media3.common.util.ListenerSet.Event
                public final void invoke(Object obj) {
                    ((AudioOutputProvider.Listener) obj).onFormatSupportChanged();
                }
            });
        }
    }

    private int getAudioOutputChannelConfig(int i) {
        DefaultAudioSink.AudioTrackProvider audioTrackProvider = this.audioTrackProvider;
        if (audioTrackProvider != null) {
            return audioTrackProvider.getAudioTrackChannelConfig(i);
        }
        return Util.getAudioTrackChannelConfig(i);
    }

    private int getAudioTrackMinBufferSize(int i, int i2, int i3) {
        int minBufferSize = AudioTrack.getMinBufferSize(i, i2, i3);
        Preconditions.checkState(minBufferSize != -2);
        return minBufferSize;
    }

    @EnsuresNonNull({"audioCapabilities"})
    private void updateAudioCapabilitiesReceiver(AudioOutputProvider.FormatConfig formatConfig) {
        verifySinglePlaybackLooper();
        AudioCapabilitiesReceiver audioCapabilitiesReceiver = this.audioCapabilitiesReceiver;
        if (audioCapabilitiesReceiver == null && this.context != null) {
            AudioCapabilitiesReceiver audioCapabilitiesReceiver2 = new AudioCapabilitiesReceiver(this.context, new AudioCapabilitiesReceiver.Listener() { // from class: androidx.media3.exoplayer.audio.AudioTrackAudioOutputProvider$$ExternalSyntheticLambda0
                @Override // androidx.media3.exoplayer.audio.AudioCapabilitiesReceiver.Listener
                public final void onAudioCapabilitiesChanged(AudioCapabilities audioCapabilities) {
                    this.f$0.onAudioCapabilitiesChanged(audioCapabilities);
                }
            }, formatConfig.audioAttributes, formatConfig.preferredDevice);
            this.audioCapabilitiesReceiver = audioCapabilitiesReceiver2;
            this.audioCapabilities = audioCapabilitiesReceiver2.register();
        } else if (audioCapabilitiesReceiver != null) {
            if (formatConfig.preferredDevice != null) {
                this.audioCapabilitiesReceiver.setRoutedDevice(formatConfig.preferredDevice);
            }
            this.audioCapabilitiesReceiver.setAudioAttributes(formatConfig.audioAttributes);
        }
        Preconditions.checkNotNull(this.audioCapabilities);
    }

    private void verifySinglePlaybackLooper() {
        if (this.context == null) {
            return;
        }
        Looper looperMyLooper = Looper.myLooper();
        Looper looper = this.playbackLooper;
        Preconditions.checkState(looper == null || looper == looperMyLooper, "AudioTrackAudioOutputProvider accessed on multiple threads: %s and %s", getLooperThreadName(looper), getLooperThreadName(looperMyLooper));
        this.playbackLooper = looperMyLooper;
    }

    @RequiresNonNull({"audioCapabilities"})
    private int getFormatSupportLevel(AudioOutputProvider.FormatConfig formatConfig) {
        Format format = formatConfig.format;
        if (!Objects.equals(format.sampleMimeType, MimeTypes.AUDIO_RAW)) {
            return this.audioCapabilities.isPassthroughPlaybackSupported(format, formatConfig.audioAttributes) ? 2 : 0;
        }
        if (format.pcmEncoding == 2) {
            return 2;
        }
        if (!formatConfig.enableHighResolutionPcmOutput) {
            return 0;
        }
        if (Util.isEncodingLinearPcm(format.pcmEncoding)) {
            return Build.VERSION.SDK_INT < Util.getApiLevelThatAudioFormatIntroducedAudioEncoding(format.pcmEncoding) ? 0 : 2;
        }
        Log.w(TAG, "Invalid PCM encoding: " + format.pcmEncoding);
        return 0;
    }

    private AudioSink.AudioTrackConfig getAudioTrackConfig(AudioOutputProvider.OutputConfig outputConfig) {
        return new AudioSink.AudioTrackConfig(outputConfig.encoding, outputConfig.sampleRate, outputConfig.channelMask, outputConfig.isTunneling, outputConfig.isOffload, outputConfig.bufferSize);
    }

    private static String getLooperThreadName(Looper looper) {
        return looper == null ? AbstractJsonLexerKt.NULL : looper.getThread().getName();
    }

    private final class CapabilityChangeListener implements AudioTrackAudioOutput.CapabilityChangeListener {
        private CapabilityChangeListener() {
        }

        @Override // androidx.media3.exoplayer.audio.AudioTrackAudioOutput.CapabilityChangeListener
        public void onRecoverableWriteError() {
            if (AudioTrackAudioOutputProvider.this.audioCapabilitiesReceiver != null) {
                AudioTrackAudioOutputProvider.this.audioCapabilities = AudioCapabilities.DEFAULT_AUDIO_CAPABILITIES;
                AudioTrackAudioOutputProvider.this.audioCapabilitiesReceiver.overrideCapabilities(AudioCapabilities.DEFAULT_AUDIO_CAPABILITIES);
            }
        }

        @Override // androidx.media3.exoplayer.audio.AudioTrackAudioOutput.CapabilityChangeListener
        public void onRoutedDeviceChanged(AudioDeviceInfo audioDeviceInfo) {
            if (AudioTrackAudioOutputProvider.this.audioCapabilitiesReceiver != null) {
                AudioTrackAudioOutputProvider.this.audioCapabilitiesReceiver.setRoutedDevice(audioDeviceInfo);
            }
        }
    }
}
