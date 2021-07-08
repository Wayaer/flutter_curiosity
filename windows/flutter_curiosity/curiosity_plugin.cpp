#include "curiosity_plugin.h"
#include "include/method_call.h"
#include <windows.h>
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <map>
#include <memory>
#include <sstream>

namespace {

LRESULT CALLBACK MyWndProc(HWND hWnd,UINT iMessage,WPARAM wParam,LPARAM lParam);
WNDPROC oldProc;

int maxWidth = 0;
int maxHeight = 0;
int minWidth = 0;
int minHeight = 0;

class CuriosityPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CuriosityPlugin();

  virtual ~CuriosityPlugin();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

void CuriosityPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "Curiosity",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<CuriosityPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));

  HWND handle = GetActiveWindow();
  oldProc = reinterpret_cast<WNDPROC>(GetWindowLongPtr(handle, GWLP_WNDPROC));
  SetWindowLongPtr(handle, GWLP_WNDPROC, (LONG_PTR)MyWndProc);
}

CuriosityPlugin::CuriosityPlugin() {}

CuriosityPlugin::~CuriosityPlugin() {}

  void getWindowSize(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                     std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    HWND handle = GetActiveWindow();
    RECT rect;

    GetWindowRect(handle, &rect);
    LONG lWidth = rect.right - rect.left;
    LONG lHeight = rect.bottom - rect.top;

    double width = lWidth * 1.0f;
    double height = lHeight * 1.0f;

    result->Success(flutter::EncodableValue(flutter::EncodableList{flutter::EncodableValue(width), flutter::EncodableValue(height)}));
  }

  void setWindowSize(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                     std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    double width = 0;
    double height = 0;
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments)
    {
      auto width_it = arguments->find(flutter::EncodableValue("width"));
      if (width_it != arguments->end())
      {
        width = std::get<double>(width_it->second);
      }
      auto height_it = arguments->find(flutter::EncodableValue("height"));
      if (height_it != arguments->end())
      {
        height = std::get<double>(height_it->second);
      }
    }
    if (width == 0 || height == 0)
    {
      result->Error("argument_error", "width or height not provided");
      return;
    }

    HWND handle = GetActiveWindow();

    int iWidth = int(width + 0.5);
    int iHeight = int(height + 0.5);

    SetWindowPos(handle, HWND_TOP, 0, 0, iWidth, iHeight, SWP_NOMOVE);

    result->Success(flutter::EncodableValue(true));
  }

  void resetMaxWindowSize(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    maxWidth = 0;
    maxHeight = 0;
    result->Success(flutter::EncodableValue(true));
  }

  void setMinWindowSize(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    double width = 0;
    double height = 0;
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments)
    {
      auto width_it = arguments->find(flutter::EncodableValue("width"));
      if (width_it != arguments->end())
      {
        width = std::get<double>(width_it->second);
      }
      auto height_it = arguments->find(flutter::EncodableValue("height"));
      if (height_it != arguments->end())
      {
        height = std::get<double>(height_it->second);
      }
    }
    if (width == 0 || height == 0)
    {
      result->Error("argument_error", "width or height not provided");
      return;
    }

    minWidth = int(width + 0.5);
    minHeight = int(height + 0.5);
    result->Success(flutter::EncodableValue(true));
  }
  void setMaxWindowSize(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    double width = 0;
    double height = 0;
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments)
    {
      auto width_it = arguments->find(flutter::EncodableValue("width"));
      if (width_it != arguments->end())
      {
        width = std::get<double>(width_it->second);
      }
      auto height_it = arguments->find(flutter::EncodableValue("height"));
      if (height_it != arguments->end())
      {
        height = std::get<double>(height_it->second);
      }
    }
    if (width == 0 || height == 0)
    {
      result->Error("argument_error", "width or height not provided");
      return;
    }

    maxWidth = int(width + 0.5);
    maxHeight = int(height + 0.5);

    result->Success(flutter::EncodableValue(true));
  }

  void CuriosityPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    CuriosityMethodCall::MethodCall methodCall(method_call, std::move(result));

    const std::string method_name = method_call.method_name();
    if (method_name == "getWindowSize")
      getWindowSize(method_call, std::move(result));
    else if (method_name == "setWindowSize")
      setWindowSize(method_call, std::move(result));
    else if (method_name == "setFullScreen")
      methodCall.setFullscreen();
    else if (method_name == "getFullScreen")
      methodCall.getFullscreen();
    else if (method_name == "toggleFullScreen")
      methodCall.toggleFullscreen();
    else if (method_name == "setBorders")
      methodCall.setBorders();
    else if (method_name == "hasBorders")
      methodCall.hasBorders();
    else if (method_name == "toggleBorders")
      methodCall.toggleBorders();
    else if (method_name == "resetMaxWindowSize")
      resetMaxWindowSize(method_call, std::move(result));
    else if (method_name == "setMinWindowSize")
      setMinWindowSize(method_call, std::move(result));
    else if (method_name == "setMaxWindowSize")
      setMaxWindowSize(method_call, std::move(result));
    else if (method_name == "stayOnTop")
      methodCall.stayOnTop();
    else if (method_name == "focus")
      methodCall.focus();
    else
      result->NotImplemented();
  }

  LRESULT CALLBACK MyWndProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam)
  {
    if (iMessage == WM_GETMINMAXINFO)
    {
      // OutputDebugString(L"WM_GETMINMAXINFO called");

      bool changed = false;

      if (maxWidth != 0 && maxHeight != 0)
      {
        ((MINMAXINFO *)lParam)->ptMaxTrackSize.x = maxWidth;
        ((MINMAXINFO *)lParam)->ptMaxTrackSize.y = maxHeight;
        changed = true;
      }
      if (minWidth != 0 && minHeight != 0)
      {
        ((MINMAXINFO *)lParam)->ptMinTrackSize.x = minWidth;
        ((MINMAXINFO *)lParam)->ptMinTrackSize.y = minHeight;
        changed = true;
      }
      if (changed)
      {
        return FALSE;
      }
    }

    return oldProc(hWnd, iMessage, wParam, lParam);
  }

} // namespace


void CuriosityPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  CuriosityPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}