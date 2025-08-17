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
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
    this.pluginBinding = null
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.abilityBinding = binding
  }

  onDetachedFromAbility(): void {
    this.abilityBinding = null
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'exitApp':
        this.pluginBinding?.getApplicationContext().getApplicationContext().killAllProcesses()
        result.success(true)
        break;
      case 'addKeyboardListener':
        this.getMainWindow()?.on('keyboardHeightChange', (data) => this.onKeyboardHeightChange(data))
        result.success(this.getMainWindow() != null)
        break;
      case 'removeKeyboardListener':
        this.getMainWindow()?.off("keyboardHeightChange", (data) => {
          this.onKeyboardHeightChange(data)
        });
        result.success(this.getMainWindow() != null)
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
