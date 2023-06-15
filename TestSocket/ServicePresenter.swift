import Foundation

struct UnknownSDKService { // no source code, just a binary
    enum Step {
        case statusChange
        case nextStep
        // ...
        // ...
    }
    var main: String = "id"
    var current = 0

    mutating func setListener(identifier: String, completion: ((AnyObject) -> Void)) {
        completion(answers[current] as AnyObject)
        current += 1
        if current == answers.count {
            current = 0
        }
    }

    let answers = [
        "statusChange(status: SDK.SocketStatus.connecting)",
        "statusChange(status: SDK.SocketStatus.connected)",
        "statusChange(status: SDK.SocketStatus.disconnected)",
        "progressInfo(data: SDK.Service.StepProgressData(stepType: \"car\", value: 1.0, message: nil))",
        "nextStep(step: SDK.Service.Step.custom(type: \"id-back-car\", data: SDK.Service.Step.SData(retry: Optional(false), isRequired: true, additionalData: nil, availableStreamIDs: nil)))",
        "stepMessage(message: SDK.Service.StepMessage.task(step: \"fake-detection\", data: SDK.Service.StepMessageDataTask(instruction: \"detection:status:carpart\", message: Optional(\"success\"))))",
        "nextStep(step: SDK.Service.Step.custom(type: \"voice-consent\", data: SDK.Service.Step.SData(retry: Optional(false), isRequired: true, additionalData: Optional([\"startVideo\": 1]), availableStreamIDs: Optional([\"voice-consent\"]))))"
    ]
}

protocol ServicePresenterProtocol: AnyObject {
    func showStep(step: UnknownSDKService.Step)
}

class ServicePresenter {
    var selfService: UnknownSDKService
    weak var delegate: ServicePresenterProtocol?

    init(selfService: UnknownSDKService, delegate: ServicePresenterProtocol) {
        self.selfService = selfService
        self.delegate = delegate
    }

    func setup() {
        selfService.setListener(identifier: "id") { [weak self] event in // in the code is <<error type>>
            NSLog("Service Event listener: \(event)")

            // my solution, that I started but not sure of success, however all the logic is in the ViewContorller
            // so it's better than nothing
            var sdkToE = SDKToE()
            print(sdkToE.convertSDKEventToEStep("\(event)"))
            // after I created my own Step I would like to move the logic here to the Presenter
            // and then controll the View Controller with simple basic types

            // old solution
            switch event {
                /*
                 // I don't even know how it could compile :)
            case .nextStep(let step):
                self?.delegate?.showStep(step: step)
            case .progressInfo(let data):
                self?.delegate?.updateProgress(data: data)
                 */
            default:
                break
            }
        }
    }
}
