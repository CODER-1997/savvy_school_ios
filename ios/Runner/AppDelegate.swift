import UIKit
import Flutter
import MessageUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MFMessageComposeViewControllerDelegate {
    private let channelName = "sms_service"
    var flutterResult: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let smsChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

        smsChannel.setMethodCallHandler { [weak self] (call, result) in
            guard call.method == "sendSMS" else {
                result(FlutterMethodNotImplemented)
                return
            }

            if let args = call.arguments as? [String: Any],
               let recipient = args["recipient"] as? String,
               let message = args["message"] as? String {
                self?.flutterResult = result
                self?.sendSMS(recipient: recipient, message: message, controller: controller)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func sendSMS(recipient: String, message: String, controller: UIViewController) {
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            composeVC.recipients = [recipient]
            composeVC.body = message
            controller.present(composeVC, animated: true, completion: nil)
        } else {
            flutterResult?(FlutterError(code: "SMS_NOT_AVAILABLE", message: "SMS not supported on this device", details: nil))
            flutterResult = nil
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            switch result {
            case .sent:
                self.flutterResult?(nil)
            case .failed:
                self.flutterResult?(FlutterError(code: "SEND_FAILED", message: "Failed to send SMS", details: nil))
            case .cancelled:
                self.flutterResult?(FlutterError(code: "CANCELLED", message: "SMS cancelled by user", details: nil))
            @unknown default:
                self.flutterResult?(FlutterError(code: "UNKNOWN", message: "Unknown result", details: nil))
            }
            self.flutterResult = nil
        }
    }
}
