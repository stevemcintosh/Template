import Foundation
import UIKit

public extension UINavigationController {
    
   func startAnimating() {
        for i in self.view.subviews {
            if i.tag == 999 {
                if let progressViewHorizontal: ProgressBarIndeterminate = i as? ProgressBarIndeterminate {
                    progressViewHorizontal.indeterminate = true
                    self.view.bringSubview(toFront: progressViewHorizontal)
                }
            } else {
                let progressViewHorizontal: ProgressBarIndeterminate = ProgressBarIndeterminate.init(frame: self.navigationBar.frame)
                progressViewHorizontal.tag = 999;
                progressViewHorizontal.indeterminate = true
                self.view.addSubview(progressViewHorizontal)
                self.view.bringSubview(toFront: progressViewHorizontal)
            }
        }
    }

   func stopAnimating() {
        for i in self.view.subviews {
            if i.tag == 999 {
                if let progressViewHorizontal: ProgressBarIndeterminate = i as? ProgressBarIndeterminate {
                    DispatchQueue.main.async {
                        progressViewHorizontal.indeterminate = false
                        progressViewHorizontal.removeFromSuperview()
                    }
                }
            }
        }
    }
	
	override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: nil) { (transitionContext) in
			for i in self.view.subviews {
				if i.tag == 999 {
					if let progressViewHorizontal: ProgressBarIndeterminate = i as? ProgressBarIndeterminate {
						self.stopAnimating()
						let frame = self.navigationBar.frame
						progressViewHorizontal.frame.origin.y = frame.origin.y - UIApplication.shared.statusBarFrame.size.height
						progressViewHorizontal.frame.size.width = frame.size.width
						self.startAnimating()
					}
					break
				}
			}
		}
	}
}
