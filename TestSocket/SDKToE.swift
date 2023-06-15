import Foundation

struct SDKToE {
    var status: EStatus = .unknown
    var step: EStep = .unknown

    mutating func convertSDKEventToEStep(_ event: String) -> EStep {
        switch event {
        // MARK: - event is a statusChange
        case change + EStatus.connecting.rawValue + close:
            status = .connecting
            step = .statusChanged
        case change + EStatus.connected.rawValue + close:
            status = .connected
            step = .statusChanged
        case change + EStatus.disconnected.rawValue + close:
            status = .disconnected
            step = .statusChanged
        default:
            // MARK: - event is a step, continue parsing
            step = parseStep(event)
        }
        return step
    }

    // MARK: - private
    private func parseStep(_ input: String) -> EStep {
        switch input {
        case let step where step.contains(next):
            return parseNextStep(step)
        default:
            print("G -> EVENT: \(input)")
            return .failedToParse
        }
    }

    private func parseNextStep(_ input: String) -> EStep {
        switch input {
        case let step where step.contains(EType.finished.rawValue):
            return .nextStep(.end(type: .finished))
        default:
            guard let step = parseNext(input) else {
                return .failedToParse
            }
            return .nextStep(step)
        }

        func parseNext(_ input: String) -> NextStep? {
            guard let data = parseData(input) else { return nil }
            switch input {
            case let step where step.contains(EType.voiceConsent.rawValue):
                return .custom(type: .voiceConsent, data: data)
            case let step where step.contains(EType.fakeDetection.rawValue):
                return .custom(type: .fakeDetection, data: data)
            case let step where step.contains(EType.idBackCar.rawValue):
                return .custom(type: .idBackCar, data: data)
            default:
                return nil
            }
        }
    }

    private func parseData(_ input: String) -> EData? {
        guard let startIndex = input.range(of: "SData")?.upperBound,
              let endIndex = input.range(of: "))")?.upperBound else {
            return nil
        }
        let substring = "{" + String(input[input.index(after: startIndex)..<endIndex]) + "}"
        let clearString = clearString(substring)

        print("G -> ", clearString)

        guard let jsonData = clearString.data(using: .utf8) else {
            print("returnolt")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(EData.self, from: jsonData)
            return data
        } catch {
            print("error: \(error)")
            return nil
        }
    }

    private func clearString(_ input: String) -> String {
        replaceBrackets(input)
            .replacingOccurrences(of: "Optional(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "retry", with: "\"retry\"")
            .replacingOccurrences(of: "isRequired", with: "\"isRequired\"")
            .replacingOccurrences(of: "additionalData", with: "\"additionalData\"")
            .replacingOccurrences(of: "availableStreamIDs", with: "\"availableStreamIDs\"")
    }

    private func replaceBrackets(_ input: String) -> String {
        let pattern = #"(additionalData:.*?)\[(.*?)\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let _ = NSRange(input.startIndex..<input.endIndex, in: input).toRange() else {
            return input
        }
        let replacedString = regex.stringByReplacingMatches(in: input, range: NSRange(input.startIndex..<input.endIndex, in: input), withTemplate: "$1{$2}")
        return replacedString
    }

    // MARK: - Constants
    private let next = "nextStep(step: SDK.Service.Step."
    private let change = "statusChange(status: SDK.SocketStatus."
    private let close = ")"
}
