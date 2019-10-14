import UIKit
import MessageUI

protocol Callable {
    func call(_ phone: String)
    func chat(_ phone: String, message: String)
    func email(_ email: String, message: String)
}

extension Callable where Self: UIViewController {
  func call(_ phone: String) {
      if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
          if #available(iOS 10, *) {
              UIApplication.shared.open(url)
          } else {
              UIApplication.shared.openURL(url)
          }
      }
  }
  
  func sms(_ phone: String) {
    if let url = URL(string: "sms://\(phone)"), UIApplication.shared.canOpenURL(url) {
      if #available(iOS 10, *) {
        UIApplication.shared.open(url)
      } else {
        UIApplication.shared.openURL(url)
      }
    }
  }
    
    func chat(_ phone: String, message: String) {
        let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(phone)&text=\(message)")!
        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
        }
    }
    
    func email(_ email: String, message: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    
}


extension UIViewController: MFMailComposeViewControllerDelegate {
    private func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
