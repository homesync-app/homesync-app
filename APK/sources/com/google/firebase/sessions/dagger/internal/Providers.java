package com.google.firebase.sessions.dagger.internal;

/* JADX INFO: loaded from: classes3.dex */
public final class Providers {
    public static <T> Provider<T> asDaggerProvider(final javax.inject.Provider<T> provider) {
        Preconditions.checkNotNull(provider);
        return new Provider<T>() { // from class: com.google.firebase.sessions.dagger.internal.Providers.1
            @Override // javax.inject.Provider
            public T get() {
                return (T) provider.get();
            }
        };
    }

    private Providers() {
    }
}
