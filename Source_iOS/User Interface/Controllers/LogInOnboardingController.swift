import UIKit
import ProcedureKit

class LoginOnboardingController : ViewController {

    let procedureQueue = ProcedureQueue()

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    var loginOnboardingPageViewController: LoginOnboardingPageViewController? {
        didSet {
            loginOnboardingPageViewController?.loginOnboardingDelegate = self
        }
    }

    //    lazy var fabric: Fabric = Fabric.with([Crashlytics.self])
    static var controller: LoginOnboardingController? {
        willSet {
            self.controller = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        LoginOnboardingController.controller = self
        configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.addTarget(self, action: #selector(LoginOnboardingController.didChangePageControlValue), for: .valueChanged)
    }
    
    func configure() {
        UIApplication.shared.keyWindow?.rootViewController = LoginOnboardingController.controller
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginOnboardingPageViewController = segue.destination as? LoginOnboardingPageViewController {
            self.loginOnboardingPageViewController = loginOnboardingPageViewController
        }
    }
    
    @IBAction func didTapNextButton(_ sender: UIButton) {
        loginOnboardingPageViewController?.scrollToNextViewController()
    }
    
    /**
    Fired when the user taps on the pageControl to change its current page.
    */
	@objc func didChangePageControlValue() {
        loginOnboardingPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
    
}

extension LoginOnboardingController: LoginOnboardingPageViewControllerDelegate {
    
    func LoginOnboardingPageViewController(_ loginOnboardingPageViewController: LoginOnboardingPageViewController,
                                    didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func LoginOnboardingPageViewController(_ loginOnboardingPageViewController: LoginOnboardingPageViewController,
                                    didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
