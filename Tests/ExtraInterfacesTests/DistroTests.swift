import ControlMsgs
import MoveitMsgs
import SwiftROS2CDR
import SwiftROS2Messages
import XCTest

final class DistroTests: XCTestCase {
    func testGripperCommandTypeHash() {
        XCTAssertEqual(
            GripperCommand.typeInfo.typeHash,
            "RIHS01_57eb8f326c9889ca8bb34ead82cc94cc09bf6bc5c3b6c09546dca3a00b589890")
    }

    func testServoStatusTypeHash() {
        XCTAssertEqual(
            ServoStatus.typeInfo.typeHash,
            "RIHS01_882a75f7648d6f8a9bf528e4787f51c58f2d5d88b702e450443d99f270e6936b")
    }

    private func encoded<T: CDRCodable>(_ value: T, legacy: Bool) throws -> Data {
        let encoder = CDREncoder(isLegacySchema: legacy)
        encoder.writeEncapsulationHeader()
        try value.encode(to: encoder)
        return encoder.getData()
    }

    func testGripperCommandHasNoLegacyShape() throws {
        let command = GripperCommand(position: 0.04, maxEffort: 25.5)
        XCTAssertEqual(try encoded(command, legacy: true), try encoded(command, legacy: false))
    }

    func testServoStatusHasNoLegacyShape() throws {
        let status = ServoStatus(code: ServoStatus.HALT_FOR_COLLISION, message: "collision")
        XCTAssertEqual(try encoded(status, legacy: true), try encoded(status, legacy: false))
    }
}
