import ControlMsgs
import MoveitMsgs
import SwiftROS2CDR
import SwiftROS2Messages
import XCTest

final class RoundTripTests: XCTestCase {
    private func roundTrip<T: CDRCodable & Equatable>(_ value: T, file: StaticString = #filePath, line: UInt = #line) throws
        -> Data
    {
        let encoder = CDREncoder()
        encoder.writeEncapsulationHeader()
        try value.encode(to: encoder)
        let bytes = encoder.getData()
        XCTAssertEqual(Array(bytes.prefix(4)), [0x00, 0x01, 0x00, 0x00], file: file, line: line)
        let decoded = try T(from: try CDRDecoder(data: bytes))
        XCTAssertEqual(decoded, value, file: file, line: line)
        return bytes
    }

    func testGripperCommand() throws {
        let bytes = try roundTrip(GripperCommand(position: 0.04, maxEffort: 25.5))
        // 4-byte header + two float64.
        XCTAssertEqual(bytes.count, 4 + 16)
    }

    func testGripperCommandActionGoal() throws {
        _ = try roundTrip(GripperCommandAction.Goal(command: GripperCommand(position: 0.02, maxEffort: 10)))
    }

    func testGripperCommandActionResult() throws {
        _ = try roundTrip(
            GripperCommandAction.Result(position: 0.03, effort: 4.5, stalled: true, reachedGoal: false))
    }

    func testGripperCommandActionFeedback() throws {
        _ = try roundTrip(
            GripperCommandAction.Feedback(position: 0.01, effort: 1.25, stalled: false, reachedGoal: true))
    }

    func testServoCommandTypeRequest() throws {
        for command in [
            ServoCommandTypeRequest.JOINT_JOG, ServoCommandTypeRequest.TWIST, ServoCommandTypeRequest.POSE,
        ] {
            let bytes = try roundTrip(ServoCommandTypeRequest(commandType: command))
            XCTAssertEqual(bytes.last, UInt8(bitPattern: command))
        }
    }

    func testServoCommandTypeResponse() throws {
        _ = try roundTrip(ServoCommandTypeResponse(success: true))
        _ = try roundTrip(ServoCommandTypeResponse(success: false))
    }

    func testServoStatusWithNegativeCodeAndNonASCIIMessage() throws {
        let status = ServoStatus(code: ServoStatus.INVALID, message: "特異点 — halt ✓")
        _ = try roundTrip(status)
        XCTAssertEqual(status.code, -1)
    }
}
