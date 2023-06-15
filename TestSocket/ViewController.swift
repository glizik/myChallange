import UIKit

class ViewController: UIViewController {
    private var presenter: ServicePresenter?
    private var selfService: UnknownSDKService = UnknownSDKService()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ServicePresenter(selfService: selfService, delegate: self)
        presenter?.setup()
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        presenter?.setup()
    }
}

extension ViewController: ServicePresenterProtocol {
    func showStep(step: UnknownSDKService.Step) {
        switch step {
        case .statusChange:
            print("a")
        case .nextStep:
            print("b")
        default:
            print("")
        }
        /*
         106 lines of cases in a Massive ViewController
         */
    }
}
