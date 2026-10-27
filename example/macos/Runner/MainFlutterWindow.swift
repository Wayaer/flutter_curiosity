import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // The Flutter template opens with the frame from MainMenu.xib. Use a
    // comfortable desktop frame so the API cards and the navigation rail have
    // enough room on macOS.
    self.setContentSize(NSSize(width: 1120, height: 760))
    self.minSize = NSSize(width: 720, height: 560)
    self.center()
  }
}
