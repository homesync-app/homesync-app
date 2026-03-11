package androidx.media3.common.audio;

import android.util.Pair;
import androidx.media3.common.C;
import androidx.media3.common.audio.DefaultGainProvider;
import androidx.media3.common.audio.GainProcessor;
import androidx.media3.common.util.Util;
import com.google.common.base.Function;
import com.google.common.base.Preconditions;
import com.google.common.collect.Range;
import com.google.common.collect.TreeRangeMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class DefaultGainProvider implements GainProcessor.GainProvider {
    private static final float GAIN_UNSET = -3.4028235E38f;
    private final float defaultGain;
    private final TreeRangeMap<Long, Function<Pair<Long, Integer>, Float>> gainMap;
    public static final FadeProvider FADE_IN_LINEAR = new FadeProvider() { // from class: androidx.media3.common.audio.DefaultGainProvider$$ExternalSyntheticLambda0
        @Override // androidx.media3.common.audio.DefaultGainProvider.FadeProvider
        public final float getGainFactorAt(long j, long j2) {
            return DefaultGainProvider.lambda$static$0(j, j2);
        }
    };
    public static final FadeProvider FADE_OUT_LINEAR = new FadeProvider() { // from class: androidx.media3.common.audio.DefaultGainProvider$$ExternalSyntheticLambda1
        @Override // androidx.media3.common.audio.DefaultGainProvider.FadeProvider
        public final float getGainFactorAt(long j, long j2) {
            return DefaultGainProvider.lambda$static$1(j, j2);
        }
    };
    public static final FadeProvider FADE_IN_EQUAL_POWER = new FadeProvider() { // from class: androidx.media3.common.audio.DefaultGainProvider$$ExternalSyntheticLambda2
        @Override // androidx.media3.common.audio.DefaultGainProvider.FadeProvider
        public final float getGainFactorAt(long j, long j2) {
            return DefaultGainProvider.lambda$static$2(j, j2);
        }
    };
    public static final FadeProvider FADE_OUT_EQUAL_POWER = new FadeProvider() { // from class: androidx.media3.common.audio.DefaultGainProvider$$ExternalSyntheticLambda3
        @Override // androidx.media3.common.audio.DefaultGainProvider.FadeProvider
        public final float getGainFactorAt(long j, long j2) {
            return DefaultGainProvider.lambda$static$3(j, j2);
        }
    };

    public interface FadeProvider {
        float getGainFactorAt(long j, long j2);
    }

    static /* synthetic */ float lambda$static$0(long j, long j2) {
        return j / j2;
    }

    static /* synthetic */ float lambda$static$1(long j, long j2) {
        return (j2 - j) / j2;
    }

    public static final class Builder {
        private final float defaultGain;
        private final TreeRangeMap<Long, Function<Pair<Long, Integer>, Float>> gainMap;

        public Builder(float f) {
            TreeRangeMap<Long, Function<Pair<Long, Integer>, Float>> treeRangeMapCreate = TreeRangeMap.create();
            this.gainMap = treeRangeMapCreate;
            this.defaultGain = f;
            treeRangeMapCreate.put(Range.all(), new Function() { // from class: androidx.media3.common.audio.DefaultGainProvider$Builder$$ExternalSyntheticLambda0
                @Override // com.google.common.base.Function
                public final Object apply(Object obj) {
                    return Float.valueOf(-3.4028235E38f);
                }
            });
        }

        public Builder addFadeAt(final long j, final long j2, final FadeProvider fadeProvider) {
            Preconditions.checkArgument(j >= 0);
            Preconditions.checkArgument(j2 > 1);
            this.gainMap.put(Range.closedOpen(Long.valueOf(j), Long.valueOf(j + j2)), new Function() { // from class: androidx.media3.common.audio.DefaultGainProvider$Builder$$ExternalSyntheticLambda1
                @Override // com.google.common.base.Function
                public final Object apply(Object obj) {
                    return DefaultGainProvider.Builder.lambda$addFadeAt$1(j, fadeProvider, j2, (Pair) obj);
                }
            });
            return this;
        }

        static /* synthetic */ Float lambda$addFadeAt$1(long j, FadeProvider fadeProvider, long j2, Pair pair) {
            int iIntValue = ((Integer) pair.second).intValue();
            return Float.valueOf(fadeProvider.getGainFactorAt(((Long) pair.first).longValue() - Util.durationUsToSampleCount(j, iIntValue), Util.durationUsToSampleCount(j2, iIntValue)));
        }

        public DefaultGainProvider build() {
            return new DefaultGainProvider(this.gainMap, this.defaultGain);
        }
    }

    static /* synthetic */ float lambda$static$2(long j, long j2) {
        return (float) Math.sin((j * 1.5707963267948966d) / j2);
    }

    static /* synthetic */ float lambda$static$3(long j, long j2) {
        return (float) Math.cos((j * 1.5707963267948966d) / j2);
    }

    private DefaultGainProvider(TreeRangeMap<Long, Function<Pair<Long, Integer>, Float>> treeRangeMap, float f) {
        TreeRangeMap<Long, Function<Pair<Long, Integer>, Float>> treeRangeMapCreate = TreeRangeMap.create();
        this.gainMap = treeRangeMapCreate;
        treeRangeMapCreate.putAll(treeRangeMap);
        this.defaultGain = f;
    }

    @Override // androidx.media3.common.audio.GainProcessor.GainProvider
    public float getGainFactorAtSamplePosition(long j, int i) {
        Preconditions.checkState(i > 0);
        Preconditions.checkArgument(j >= 0);
        float fFloatValue = ((Float) ((Function) Preconditions.checkNotNull(this.gainMap.get(Long.valueOf(Util.sampleCountToDurationUs(j, i))))).apply(Pair.create(Long.valueOf(j), Integer.valueOf(i)))).floatValue();
        return fFloatValue == -3.4028235E38f ? this.defaultGain : fFloatValue;
    }

    @Override // androidx.media3.common.audio.GainProcessor.GainProvider
    public long isUnityUntil(long j, int i) {
        Preconditions.checkState(i > 0);
        Preconditions.checkArgument(j >= 0);
        Map.Entry entry = (Map.Entry) Preconditions.checkNotNull(this.gainMap.getEntry(Long.valueOf(Util.sampleCountToDurationUs(j, i))));
        float fFloatValue = ((Float) ((Function) entry.getValue()).apply(Pair.create(Long.valueOf(j), Integer.valueOf(i)))).floatValue();
        if (fFloatValue == 1.0f) {
            return j + 1;
        }
        if (this.defaultGain != 1.0f || fFloatValue != -3.4028235E38f) {
            return C.TIME_UNSET;
        }
        if (((Range) entry.getKey()).hasUpperBound()) {
            return Util.durationUsToSampleCount(((Long) ((Range) entry.getKey()).upperEndpoint()).longValue(), i);
        }
        return Long.MIN_VALUE;
    }
}
