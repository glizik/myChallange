import Foundation

enum EStatus: String {
    case connecting
    case connected
    case disconnected
    case unknown
}

enum NextStep {
    case custom(type: EType, data: EData)
    case end(type: EType)
}

enum EStep {
    case nextStep(_ step: NextStep)
    case statusChanged
    case unHandledEvent(event: String)
    case failedToParse
    case unknown
}

enum EType: String {
    case voiceConsent = "voice-consent"
    case fakeDetection = "fake-detection"
    case idBackCar = "id-back-car"
    case finished = "finished"
}

struct EContainer {
    let step: EStep?
    let status: EStatus?
}

struct EData: Decodable {
    let retry: Bool?
    let isRequired: Bool
    let additionalData: [String: Int]?
    let availableStreamIDs: [String]?
}
