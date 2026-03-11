package androidx.media3.exoplayer.audio;

import android.media.AudioTimestamp;
import android.media.AudioTrack;
import androidx.media3.common.C;
import androidx.media3.common.util.Util;
import androidx.media3.exoplayer.audio.AudioTrackPositionTracker;

/* JADX INFO: loaded from: classes.dex */
final class AudioTimestampPoller {
    private static final int ERROR_POLL_INTERVAL_US = 500000;
    private static final int FAST_POLL_INTERVAL_US = 10000;
    private static final int INITIALIZING_DURATION_US = 500000;
    private static final long MAX_AUDIO_TIMESTAMP_OFFSET_US = 5000000;
    private static final long MAX_POSITION_DRIFT_ADVANCING_TIMESTAMP_US = 1000;
    private static final int SLOW_POLL_INTERVAL_US = 10000000;
    private static final int STATE_ERROR = 4;
    private static final int STATE_INITIALIZING = 0;
    private static final int STATE_NO_TIMESTAMP = 3;
    private static final int STATE_TIMESTAMP = 1;
    private static final int STATE_TIMESTAMP_ADVANCING = 2;
    private static final int WAIT_FOR_ADVANCE_DURATION_US = 2000000;
    private final AudioTimestampWrapper audioTimestamp;
    private final AudioTrackPositionTracker.Listener errorListener;
    private long initialTimestampPositionFrames;
    private long initialTimestampSystemTimeUs;
    private long initializeSystemTimeUs;
    private long lastTimestampSampleTimeUs;
    private long sampleIntervalUs;
    private final int sampleRate;
    private int state;

    public AudioTimestampPoller(AudioTrack audioTrack, AudioTrackPositionTracker.Listener listener) {
        this.audioTimestamp = new AudioTimestampWrapper(audioTrack);
        this.sampleRate = audioTrack.getSampleRate();
        this.errorListener = listener;
        reset();
    }

    public void maybePollTimestamp(long j, float f, long j2, boolean z) {
        if (z || j - this.lastTimestampSampleTimeUs >= this.sampleIntervalUs) {
            this.lastTimestampSampleTimeUs = j;
            boolean zMaybeUpdateTimestamp = this.audioTimestamp.maybeUpdateTimestamp();
            if (zMaybeUpdateTimestamp) {
                checkTimestampIsPlausibleAndUpdateErrorState(j, f, j2);
            }
            int i = this.state;
            if (i == 0) {
                if (!zMaybeUpdateTimestamp) {
                    if (j - this.initializeSystemTimeUs > 500000) {
                        updateState(3);
                        return;
                    }
                    return;
                } else {
                    if (this.audioTimestamp.getTimestampSystemTimeUs() >= this.initializeSystemTimeUs) {
                        this.initialTimestampPositionFrames = this.audioTimestamp.getTimestampPositionFrames();
                        this.initialTimestampSystemTimeUs = this.audioTimestamp.getTimestampSystemTimeUs();
                        updateState(1);
                        return;
                    }
                    return;
                }
            }
            if (i == 1) {
                if (zMaybeUpdateTimestamp) {
                    if (isTimestampAdvancingFromInitialTimestamp(j, f)) {
                        updateState(2);
                        return;
                    } else if (j - this.initializeSystemTimeUs > SilenceSkippingAudioProcessor.DEFAULT_MAX_SILENCE_TO_KEEP_DURATION_US) {
                        updateState(3);
                        return;
                    } else {
                        this.initialTimestampPositionFrames = this.audioTimestamp.getTimestampPositionFrames();
                        this.initialTimestampSystemTimeUs = this.audioTimestamp.getTimestampSystemTimeUs();
                        return;
                    }
                }
                reset();
                return;
            }
            if (i == 2) {
                if (zMaybeUpdateTimestamp) {
                    return;
                }
                reset();
            } else if (i != 3) {
                if (i != 4) {
                    throw new IllegalStateException();
                }
            } else if (zMaybeUpdateTimestamp) {
                reset();
            }
        }
    }

    public boolean hasAdvancingTimestamp() {
        return this.state == 2;
    }

    public boolean isWaitingForAdvancingTimestamp() {
        int i = this.state;
        return i == 0 || i == 1;
    }

    public void reset() {
        updateState(0);
    }

    public long getTimestampPositionUs(long j, float f) {
        return computeTimestampPositionUs(j, f);
    }

    public void expectTimestampFramePositionReset() {
        this.audioTimestamp.expectTimestampFramePositionReset();
    }

    private void updateState(int i) {
        this.state = i;
        if (i == 0) {
            this.lastTimestampSampleTimeUs = 0L;
            this.initialTimestampPositionFrames = -1L;
            this.initialTimestampSystemTimeUs = C.TIME_UNSET;
            this.initializeSystemTimeUs = System.nanoTime() / 1000;
            this.sampleIntervalUs = 10000L;
            return;
        }
        if (i == 1) {
            this.sampleIntervalUs = 10000L;
            return;
        }
        if (i == 2 || i == 3) {
            this.sampleIntervalUs = 10000000L;
        } else {
            if (i == 4) {
                this.sampleIntervalUs = 500000L;
                return;
            }
            throw new IllegalStateException();
        }
    }

    private boolean isTimestampAdvancingFromInitialTimestamp(long j, float f) {
        long timestampPositionFrames = this.audioTimestamp.getTimestampPositionFrames();
        long j2 = this.initialTimestampPositionFrames;
        if (timestampPositionFrames <= j2) {
            return false;
        }
        return Math.abs(computeTimestampPositionUs(j, f) - computeTimestampPositionUs(j2, this.initialTimestampSystemTimeUs, j, f)) < 1000;
    }

    private long computeTimestampPositionUs(long j, float f) {
        return computeTimestampPositionUs(this.audioTimestamp.getTimestampPositionFrames(), this.audioTimestamp.getTimestampSystemTimeUs(), j, f);
    }

    private long computeTimestampPositionUs(long j, long j2, long j3, float f) {
        return Util.sampleCountToDurationUs(j, this.sampleRate) + Util.getMediaDurationForPlayoutDuration(j3 - j2, f);
    }

    private void checkTimestampIsPlausibleAndUpdateErrorState(long j, float f, long j2) {
        long timestampSystemTimeUs = this.audioTimestamp.getTimestampSystemTimeUs();
        long jComputeTimestampPositionUs = computeTimestampPositionUs(j, f);
        if (Math.abs(timestampSystemTimeUs - j) > 5000000) {
            this.errorListener.onSystemTimeUsMismatch(this.audioTimestamp.getTimestampPositionFrames(), timestampSystemTimeUs, j, j2);
            updateState(4);
        } else if (Math.abs(jComputeTimestampPositionUs - j2) > 5000000) {
            this.errorListener.onPositionFramesMismatch(this.audioTimestamp.getTimestampPositionFrames(), timestampSystemTimeUs, j, j2);
            updateState(4);
        } else if (this.state == 4) {
            reset();
        }
    }

    private static final class AudioTimestampWrapper {
        private long accumulatedRawTimestampFramePosition;
        private final AudioTimestamp audioTimestamp = new AudioTimestamp();
        private final AudioTrack audioTrack;
        private boolean expectTimestampFramePositionReset;
        private long lastTimestampPositionFrames;
        private long lastTimestampRawPositionFrames;
        private long rawTimestampFramePositionWrapCount;

        public AudioTimestampWrapper(AudioTrack audioTrack) {
            this.audioTrack = audioTrack;
        }

        public boolean maybeUpdateTimestamp() {
            boolean timestamp = this.audioTrack.getTimestamp(this.audioTimestamp);
            if (timestamp) {
                long j = this.audioTimestamp.framePosition;
                long j2 = this.lastTimestampRawPositionFrames;
                if (j2 > j) {
                    if (this.expectTimestampFramePositionReset) {
                        this.accumulatedRawTimestampFramePosition += j2;
                        this.expectTimestampFramePositionReset = false;
                    } else {
                        this.rawTimestampFramePositionWrapCount++;
                    }
                }
                this.lastTimestampRawPositionFrames = j;
                this.lastTimestampPositionFrames = j + this.accumulatedRawTimestampFramePosition + (this.rawTimestampFramePositionWrapCount << 32);
            }
            return timestamp;
        }

        public long getTimestampSystemTimeUs() {
            return this.audioTimestamp.nanoTime / 1000;
        }

        public long getTimestampPositionFrames() {
            return this.lastTimestampPositionFrames;
        }

        public void expectTimestampFramePositionReset() {
            this.expectTimestampFramePositionReset = true;
        }
    }
}
