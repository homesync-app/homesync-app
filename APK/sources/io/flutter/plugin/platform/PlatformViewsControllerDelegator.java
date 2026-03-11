package io.flutter.plugin.platform;

import android.content.Context;
import android.view.View;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.systemchannels.PlatformViewCreationRequest;
import io.flutter.embedding.engine.systemchannels.PlatformViewTouch;
import io.flutter.embedding.engine.systemchannels.PlatformViewsChannel;
import io.flutter.view.AccessibilityBridge;
import io.flutter.view.TextureRegistry;

/* JADX INFO: loaded from: classes.dex */
public class PlatformViewsControllerDelegator implements PlatformViewsAccessibilityDelegate, PlatformViewsChannel.PlatformViewsHandler {
    PlatformViewsController platformViewsController;
    PlatformViewsController2 platformViewsController2;

    public PlatformViewsControllerDelegator(PlatformViewsController platformViewsController, PlatformViewsController2 platformViewsController2) {
        this.platformViewsController = platformViewsController;
        this.platformViewsController2 = platformViewsController2;
    }

    @Override // io.flutter.plugin.platform.PlatformViewsAccessibilityDelegate
    public View getPlatformViewById(int i) {
        if (this.platformViewsController2.getPlatformViewById(i) != null) {
            return this.platformViewsController2.getPlatformViewById(i);
        }
        return this.platformViewsController.getPlatformViewById(i);
    }

    @Override // io.flutter.plugin.platform.PlatformViewsAccessibilityDelegate
    public boolean usesVirtualDisplay(int i) {
        if (this.platformViewsController2.getPlatformViewById(i) != null) {
            return this.platformViewsController2.usesVirtualDisplay(i);
        }
        return this.platformViewsController.usesVirtualDisplay(i);
    }

    @Override // io.flutter.plugin.platform.PlatformViewsAccessibilityDelegate
    public void attachAccessibilityBridge(AccessibilityBridge accessibilityBridge) {
        this.platformViewsController.attachAccessibilityBridge(accessibilityBridge);
        this.platformViewsController2.attachAccessibilityBridge(accessibilityBridge);
    }

    @Override // io.flutter.plugin.platform.PlatformViewsAccessibilityDelegate
    public void detachAccessibilityBridge() {
        this.platformViewsController.detachAccessibilityBridge();
        this.platformViewsController2.detachAccessibilityBridge();
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void dispose(int i) {
        if (this.platformViewsController2.getPlatformViewById(i) != null) {
            this.platformViewsController2.channelHandler.dispose(i);
        } else {
            this.platformViewsController.channelHandler.dispose(i);
        }
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void resize(PlatformViewsChannel.PlatformViewResizeRequest platformViewResizeRequest, PlatformViewsChannel.PlatformViewBufferResized platformViewBufferResized) {
        if (this.platformViewsController2.getPlatformViewById(platformViewResizeRequest.viewId) != null) {
            return;
        }
        this.platformViewsController.channelHandler.resize(platformViewResizeRequest, platformViewBufferResized);
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void offset(int i, double d, double d2) {
        if (this.platformViewsController2.getPlatformViewById(i) != null) {
            return;
        }
        this.platformViewsController.channelHandler.offset(i, d, d2);
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void onTouch(PlatformViewTouch platformViewTouch) {
        if (this.platformViewsController2.getPlatformViewById(platformViewTouch.viewId) != null) {
            this.platformViewsController2.channelHandler.onTouch(platformViewTouch);
        } else {
            this.platformViewsController.channelHandler.onTouch(platformViewTouch);
        }
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void setDirection(int i, int i2) {
        if (this.platformViewsController2.getPlatformViewById(i) != null) {
            this.platformViewsController2.channelHandler.setDirection(i, i2);
        } else {
            this.platformViewsController.channelHandler.setDirection(i, i2);
        }
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void clearFocus(int i) {
        if (this.platformViewsController2.getPlatformViewById(i) != null) {
            this.platformViewsController2.channelHandler.clearFocus(i);
        } else {
            this.platformViewsController.channelHandler.clearFocus(i);
        }
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void synchronizeToNativeViewHierarchy(boolean z) {
        this.platformViewsController.channelHandler.synchronizeToNativeViewHierarchy(z);
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public boolean isHcppEnabled() {
        return this.platformViewsController2.isHcppEnabled();
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void createForPlatformViewLayer(PlatformViewCreationRequest platformViewCreationRequest) {
        this.platformViewsController.channelHandler.createForPlatformViewLayer(platformViewCreationRequest);
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public long createForTextureLayer(PlatformViewCreationRequest platformViewCreationRequest) {
        return this.platformViewsController.channelHandler.createForTextureLayer(platformViewCreationRequest);
    }

    @Override // io.flutter.embedding.engine.systemchannels.PlatformViewsChannel.PlatformViewsHandler
    public void createPlatformViewHcpp(PlatformViewCreationRequest platformViewCreationRequest) {
        this.platformViewsController2.channelHandler.createPlatformView(platformViewCreationRequest);
    }

    public void attach(Context context, TextureRegistry textureRegistry, DartExecutor dartExecutor) {
        this.platformViewsController.attach(context, textureRegistry, dartExecutor);
        this.platformViewsController2.attach(context, dartExecutor);
        this.platformViewsController.getPlatformViewsChannel().setPlatformViewsHandler(this);
    }
}
