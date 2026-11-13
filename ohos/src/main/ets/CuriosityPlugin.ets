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
  private keyboardWindow: window.Window | null = null
  private keyboardListenerRequested: boolean = false
  static logTag: string = 'CuriosityPlugin:'

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
    this.keyboardListenerRequested = false
    this.removeKeyboardHeightChangeCallback()
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
    this.channel = null
    this.pluginBinding = null
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.abilityBinding = binding
    if (this.keyboardListenerRequested) {
      this.attachKeyboardHeightChangeCallback()
    }
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
      case 'addKeyboardListener': {
        this.keyboardListenerRequested = true
        const attached: boolean = this.attachKeyboardHeightChangeCallback()
        if (!attached) {
          this.keyboardListenerRequested = false
        }
        result.success(attached)
        break;
      }
      case 'removeKeyboardListener': {
        this.keyboardListenerRequested = false
        result.success(this.removeKeyboardHeightChangeCallback())
        break;
      }
      case 'getGPSStatus':
        result.success(this.getGPSStatus())
        break;
      case 'saveBytesImageToGallery':
        if (this.abilityBinding == null) {
          result.success(false)
          return
        }
        ImageGalleryTools.saveBytesImageToGallery(this.abilityBinding.getAbility().context, call)
          .then((value: boolean): void => {
            result.success(value)
          })
          .catch((err: Error): void => {
            Log.e(`${CuriosityPlugin.logTag} saveBytesImageToGallery error:`, err.message)
            result.success(false)
          })
        break;
      case 'saveFilePathToGallery':
        if (this.abilityBinding == null) {
          result.success(false)
          return
        }
        ImageGalleryTools.saveFilePathToGallery(this.abilityBinding.getAbility().context, call)
          .then((value: boolean): void => {
            result.success(value)
          })
          .catch((err: Error): void => {
            Log.e(`${CuriosityPlugin.logTag} saveFilePathToGallery error:`, err.message)
            result.success(false)
          })
        break;
      default:
        result.notImplemented()
    }
  }

  private attachKeyboardHeightChangeCallback(): boolean {
    if (this.keyboardHeightChangeCallback != null) {
      return true
    }
    const mainWindow = this.getMainWindow()
    if (mainWindow == null) {
      return false
    }
    const callback = (data: number): void => {
      this.onKeyboardHeightChange(data)
    }
    try {
      mainWindow.on('keyboardHeightChange', callback)
    } catch (err) {
      Log.e(`${CuriosityPlugin.logTag} on keyboardHeightChange error:`, err.message)
      return false
    }
    this.keyboardHeightChangeCallback = callback
    this.keyboardWindow = mainWindow
    return true
  }

  private removeKeyboardHeightChangeCallback(): boolean {
    const callback = this.keyboardHeightChangeCallback
    if (callback == null) {
      return false
    }
    try {
      this.keyboardWindow?.off('keyboardHeightChange', callback)
    } catch (err) {
      Log.e(`${CuriosityPlugin.logTag} off keyboardHeightChange error:`, err.message)
    }
    this.keyboardWindow = null
    this.keyboardHeightChangeCallback = null
    return true
  }

  private getMainWindow(): window.Window | null {
    if (this.abilityBinding == null) {
      return null;
    }
    try {
      return FlutterManager.getInstance().getWindowStage(this.abilityBinding.getAbility()).getMainWindowSync()
    } catch (err) {
      Log.e(`${CuriosityPlugin.logTag} getMainWindow error:`, err.message)
      return null
    }
  }

  private onKeyboardHeightChange(data: number): void {
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
