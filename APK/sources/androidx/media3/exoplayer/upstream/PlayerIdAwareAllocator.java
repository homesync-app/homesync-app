package androidx.media3.exoplayer.upstream;

import androidx.media3.exoplayer.analytics.PlayerId;

/* JADX INFO: loaded from: classes.dex */
public interface PlayerIdAwareAllocator extends Allocator {
    @Override // androidx.media3.exoplayer.upstream.Allocator
    int getTotalBytesAllocated();

    void setPlayerId(PlayerId playerId);
}
