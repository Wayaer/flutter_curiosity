import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterManager,
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import ImageGalleryTools from './ImageGalleryTools';
import { display, window } from '@kit.ArkUI';
import geoLocationManager from '@ohos.geoLocationManager';

export default class CuriosityPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private abilityBinding: AbilityPluginBinding | null = null
  private pluginBinding: FlutterPluginBinding | null = null
  private keyboardHeightChangeCallback: ((data: number) => void) | null = null
  static logTag = 'CuriosityPlugin:'

  constructor() {
  }

  getUniqueClassName(): string {
    return "CuriosityPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "Curiosity");
    this.channel.setMethodCallHandler(this)
    this.pluginBinding = binding
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.removeKeyboardHeightChangeCallback()
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
    this.channel = null
    this.pluginBinding = null
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.abilityBinding = binding
  }

  onDetachedFromAbility(): void {
    this.removeKeyboardHeightChangeCallback()
    this.abilityBinding = null
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'exitApp':
        this.pluginBinding?.getApplicationContext().getApplicationContext().killAllProcesses()
        result.success(true)
        break;
      case 'addKeyboardListener':
        if (this.keyboardHeightChangeCallback == null) {
          const callback = (data: number) => this.onKeyboardHeightChange(data)
          this.keyboardHeightChangeCallback = callback
          this.getMainWindow()?.on('keyboardHeightChange', callback)
        }
        result.success(this.keyboardHeightChangeCallback != null)
        break;
      case 'removeKeyboardListener':
        this.removeKeyboardHeightChangeCallback()
        result.success(true)
        break;
      case 'getGPSStatus':
        result.success(this.getGPSStatus())
        break;
      case 'saveBytesImageToGallery':
        if (this.abilityBinding == null) {
          result.success(false)
          return
        }
        ImageGalleryTools.saveBytesImageToGallery(this.abilityBinding.getAbility().context, call).then((value) => {
          result.success(value)
        })
        break;
      case 'saveFilePathToGallery':
        if (this.abilityBinding == null) {
          result.success(false)
          return
        }
        ImageGalleryTools.saveFilePathToGallery(this.abilityBinding.getAbility().context, call).then((value) => {
          result.success(value)
        })
        break;
      default:
        result.notImplemented()
    }
  }

  private removeKeyboardHeightChangeCallback(): void {
    const callback = this.keyboardHeightChangeCallback
    if (callback != null) {
      this.getMainWindow()?.off('keyboardHeightChange', callback)
      this.keyboardHeightChangeCallback = null
    }
  }

  private getMainWindow(): window.Window | null {
    if (this.abilityBinding != null) {
      return FlutterManager.getInstance().getWindowStage(this.abilityBinding.getAbility()).getMainWindowSync()
    }
    return null;
  }

  private onKeyboardHeightChange(data: number) {
    if (this.channel == null) {
      return
    }
    const defaultDisplay = display.getDefaultDisplaySync()
    this.channel.invokeMethod('onKeyboardStatus', {
      'density': defaultDisplay.densityPixels,
      'displayWidth': defaultDisplay.width,
      'displayHeight': defaultDisplay.height,
      'keyboardHeight': data,
    })
  }

  private getGPSStatus(): boolean {
    try {
      return geoLocationManager.isLocationEnabled()
    } catch (error) {
      Log.e(`${CuriosityPlugin.logTag} getGPSStatus error:`, error.message);
      return false;
    }
  }
}
