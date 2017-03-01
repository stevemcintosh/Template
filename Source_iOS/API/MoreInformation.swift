import Foundation
import ProcedureKit
import SafariServices

class MoreInformation: Procedure {
    // MARK: Properties

    let url: URL
    
    // MARK: Initialization
    
    init(url: URL) {
        self.url = url
        super.init(disableAutomaticFinishing: false)
    }
    
    // MARK: Overrides
 
    override func execute() {
		
		guard !cancelled else { return }
		
		DispatchQueue.main.async {
            self.showSafariViewController()
        }
    }
    
    private func showSafariViewController() {
        if let context = UIApplication.shared.keyWindow?.rootViewController {
            let safari = SFSafariViewController(url: self.url, entersReaderIfAvailable: false)
            safari.delegate = self
			context.present(safari, animated: true, completion: { [weak weakSelf = self] in
				weakSelf?.finish()
			})
        }
        else {
            finish()
        }
    }
}

extension MoreInformation: SFSafariViewControllerDelegate {
    private func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismiss(animated: true) {
            self.finish()
        }
    }
}
