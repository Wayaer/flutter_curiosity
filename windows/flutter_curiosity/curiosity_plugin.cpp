#include "curiosity_plugin.h"
#include "include/borders.h"
#include <windows.h>
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <map>
#include <memory>
#include <sstream>

void CuriosityPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  CuriosityPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
namespace
{

  LRESULT CALLBACK MyWndProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);
  WNDPROC oldProc;

  int maxWidth = 0;
  int maxHeight = 0;
  int minWidth = 0;
  int minHeight = 0;

  class CuriosityPlugin : public flutter::Plugin
  {
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
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "Curiosity",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<CuriosityPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });
    registrar->AddPlugin(std::move(plugin));
    HWND handle = GetActiveWindow();
    oldProc = reinterpret_cast<WNDPROC>(GetWindowLongPtr(handle, GWLP_WNDPROC));
    SetWindowLongPtr(handle, GWLP_WNDPROC, (LONG_PTR)MyWndProc);
  }
  LRESULT CALLBACK MyWndProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam)
  {
    if (iMessage == WM_GETMINMAXINFO)
    {
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
  CuriosityPlugin::CuriosityPlugin() {}

  CuriosityPlugin::~CuriosityPlugin() {}
  void CuriosityPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    const std::string method_name = method_call.method_name();
    if (method_name == "getWindowSize")
      getWindowSize(std::move(result));
    else if (method_name == "setWindowSize")
      setWindowSize(method_call, std::move(result));
    else if (method_name == "resetMaxWindowSize")
      resetMaxWindowSize(std::move(result));
    else if (method_name == "setMinWindowSize")
      setMinWindowSize(method_call, std::move(result));
    else if (method_name == "setMaxWindowSize")
      setMaxWindowSize(method_call, std::move(result));
    else if (method_name == "setFullScreen")
      setFullScreen(method_call, std::move(result));
    else if (method_name == "getFullScreen")
      getFullScreen(std::move(result));
    else if (method_name == "toggleFullScreen")
      toggleFullScreen(std::move(result));
    else if (method_name == "setBorders")
      setBorders(method_call, std::move(result));
    else if (method_name == "hasBorders")
      hasBorders(std::move(result));
    else if (method_name == "toggleBorders")
      toggleBorders(std::move(result));
    else if (method_name == "stayOnTop")
      stayOnTop(method_call, std::move(result));
    else if (method_name == "focus")
      focus(std::move(result));
    else
      result->NotImplemented();
  }

  void getWindowSize(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
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

  void resetMaxWindowSize(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
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

  void setFullscreen(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                 std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    bool fullscreen = false;
    if (arguments)
    {
      auto fs_it = arguments->find(flutter::EncodableValue("fullscreen"));
      if (fs_it != arguments->end())
      {
        fullscreen = std::get<bool>(fs_it->second);
      }
    }
    HWND handle = GetActiveWindow();
    WINDOWPLACEMENT placement;
    GetWindowPlacement(handle, &placement);
    if (fullscreen)
    {
      placement.showCmd = SW_MAXIMIZE;
      SetWindowPlacement(handle, &placement);
    }
    else
    {
      placement.showCmd = SW_NORMAL;
      SetWindowPlacement(handle, &placement);
    }
    result->Success(flutter::EncodableValue(true));
  }

  void getFullscreen(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    HWND handle = GetActiveWindow();
    WINDOWPLACEMENT placement;
    GetWindowPlacement(handle, &placement);

    result->Success(flutter::EncodableValue(placement.showCmd == SW_MAXIMIZE));
  }
  void toggleFullscreen(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    HWND handle = GetActiveWindow();
    WINDOWPLACEMENT placement;
    GetWindowPlacement(handle, &placement);
    if (placement.showCmd == SW_MAXIMIZE)
    {
      placement.showCmd = SW_NORMAL;
      SetWindowPlacement(handle, &placement);
    }
    else
    {
      placement.showCmd = SW_MAXIMIZE;
      SetWindowPlacement(handle, &placement);
    }
    result->Success(flutter::EncodableValue(true));
  }

  void setBorders(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                              std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    bool border = false;
    if (arguments)
    {
      auto fs_it = arguments->find(flutter::EncodableValue("border"));
      if (fs_it != arguments->end())
      {
        border = std::get<bool>(fs_it->second);
      }
    }

    HWND hWnd = GetActiveWindow();
    Borders::setBorders(&hWnd, border, true);
    result->Success(flutter::EncodableValue(true));
  }

  void hasBorders(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    HWND hWnd = GetActiveWindow();
    result->Success(flutter::EncodableValue(Borders::hasBorders(&hWnd)));
  }

  void toggleBorders(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    HWND hWnd = GetActiveWindow();
    Borders::toggleBorders(&hWnd, true);
    result->Success(flutter::EncodableValue(true));
  }

  void stayOnTop(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    bool stayOnTop = false;
    if (arguments)
    {
      auto fs_it = arguments->find(flutter::EncodableValue("stayOnTop"));
      if (fs_it != arguments->end())
      {
        stayOnTop = std::get<bool>(fs_it->second);
      }
    }

    HWND hWnd = GetActiveWindow();
    RECT rect;
    GetWindowRect(hWnd, &rect);
    SetWindowPos(hWnd, stayOnTop ? HWND_TOPMOST : HWND_NOTOPMOST, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, SWP_SHOWWINDOW);
    result->Success(flutter::EncodableValue(true));
  }

  void focus(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    HWND hWnd = GetActiveWindow();
    SetFocus(hWnd);
    result->Success(flutter::EncodableValue(true));
  }

}
