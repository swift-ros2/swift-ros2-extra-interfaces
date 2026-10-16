import ControlMsgs
import MoveitMsgs
import SwiftROS2Messages
import XCTest

/// The names, field labels and constants Conduit binds. A regeneration that changes one must fail here.
final class ContractTests: XCTestCase {
    func testGripperCommandNames() {
        XCTAssertEqual(GripperCommand.typeInfo.typeName, "control_msgs/msg/GripperCommand")
        XCTAssertEqual(GripperCommandAction.typeInfo.actionName, "control_msgs/action/GripperCommand")
        let command = GripperCommand(position: 1.5, maxEffort: 2.5)
        XCTAssertEqual(command.position, 1.5)
        XCTAssertEqual(command.maxEffort, 2.5)
        XCTAssertEqual(GripperCommandAction.Goal(command: command).command, command)
    }

    func testServoCommandTypeNames() {
        let info = ServoCommandTypeSrv.typeInfo
        XCTAssertEqual(info.serviceName, "moveit_msgs/srv/ServoCommandType")
        XCTAssertEqual(info.requestTypeName, "moveit_msgs/srv/ServoCommandType_Request")
        XCTAssertEqual(info.responseTypeName, "moveit_msgs/srv/ServoCommandType_Response")
        XCTAssertEqual(ServoCommandTypeRequest(commandType: 2).commandType, 2)
        XCTAssertTrue(ServoCommandTypeResponse(success: true).success)
    }

    func testServoStatusName() {
        XCTAssertEqual(ServoStatus.typeInfo.typeName, "moveit_msgs/msg/ServoStatus")
        let status = ServoStatus(code: 3, message: "m")
        XCTAssertEqual(status.code, 3)
        XCTAssertEqual(status.message, "m")
    }

    func testServoCommandTypeRequestConstants() {
        XCTAssertEqual(ServoCommandTypeRequest.JOINT_JOG, 0)
        XCTAssertEqual(ServoCommandTypeRequest.TWIST, 1)
        XCTAssertEqual(ServoCommandTypeRequest.POSE, 2)
    }

    func testServoStatusConstants() {
        XCTAssertEqual(ServoStatus.INVALID, -1)
        XCTAssertEqual(ServoStatus.NO_WARNING, 0)
        XCTAssertEqual(ServoStatus.DECELERATE_FOR_APPROACHING_SINGULARITY, 1)
        XCTAssertEqual(ServoStatus.HALT_FOR_SINGULARITY, 2)
        XCTAssertEqual(ServoStatus.DECELERATE_FOR_LEAVING_SINGULARITY, 3)
        XCTAssertEqual(ServoStatus.DECELERATE_FOR_COLLISION, 4)
        XCTAssertEqual(ServoStatus.HALT_FOR_COLLISION, 5)
        XCTAssertEqual(ServoStatus.JOINT_BOUND, 6)
    }
}
