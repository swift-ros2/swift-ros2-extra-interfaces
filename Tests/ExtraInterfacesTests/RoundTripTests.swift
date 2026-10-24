import BuiltinInterfaces
import ControlMsgs
import MoveitMsgs
import SensorMsgs
import SwiftROS2CDR
import SwiftROS2Messages
import UniqueIdentifierMsgs
import XCTest

final class RoundTripTests: XCTestCase {
    private func roundTrip<T: CDRCodable & Equatable>(_ value: T, file: StaticString = #filePath, line: UInt = #line)
        throws
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

    // MARK: - MoveGroup

    /// Every distribution the MoveGroup closure is generated for, plus Rolling (Lyrical shape).
    private let moveGroupDistros: [ROS2Distro] = [.jazzy, .kilted, .lyrical, .rolling]

    private func roundTrip<T: CDRCodable & Equatable>(
        _ value: T, distro: ROS2Distro, file: StaticString = #filePath, line: UInt = #line
    ) throws {
        let encoder = CDREncoder(distro: distro)
        encoder.writeEncapsulationHeader()
        try value.encode(to: encoder)
        let bytes = encoder.getData()
        let decoded = try T(from: try CDRDecoder(data: bytes, distro: distro))
        XCTAssertEqual(decoded, value, "\(distro)", file: file, line: line)
    }

    /// A value whose `smoothnessLevel` survives only where it is encoded.
    private func expected(_ request: MotionPlanRequest, on distro: ROS2Distro) -> MotionPlanRequest {
        var request = request
        if distro < .lyrical { request.smoothnessLevel = 0 }
        return request
    }

    private var goal: MoveGroupAction.Goal {
        let joints = ["panda_joint1", "panda_joint2"].enumerated().map { index, name in
            JointConstraint(
                jointName: name, position: Double(index) * 0.25, toleranceAbove: 0.01, toleranceBelow: 0.01,
                weight: 1.0)
        }
        var startState = RobotState()
        startState.jointState = JointState(name: ["panda_joint1"], position: [0.1])
        startState.isDiff = true
        return MoveGroupAction.Goal(
            request: MotionPlanRequest(
                startState: startState,
                goalConstraints: [Constraints(jointConstraints: joints)],
                groupName: "panda_arm",
                numPlanningAttempts: 3,
                allowedPlanningTime: 5,
                maxVelocityScalingFactor: 0.1,
                maxAccelerationScalingFactor: 0.1,
                smoothnessLevel: 0.5),
            planningOptions: PlanningOptions(planOnly: false, replan: true, replanAttempts: 2))
    }

    func testMoveGroupGoalPerDistribution() throws {
        for distro in moveGroupDistros {
            var value = goal
            value.request = expected(value.request, on: distro)
            try roundTrip(value, distro: distro)
        }
    }

    func testMoveGroupGoalDropsSmoothnessLevelBeforeLyrical() throws {
        for distro in [ROS2Distro.jazzy, .kilted] {
            let encoder = CDREncoder(distro: distro)
            encoder.writeEncapsulationHeader()
            try goal.encode(to: encoder)
            let decoded = try MoveGroupAction.Goal(from: CDRDecoder(data: encoder.getData(), distro: distro))
            XCTAssertEqual(decoded.request.smoothnessLevel, 0)
            XCTAssertEqual(decoded.request.groupName, "panda_arm")
        }
    }

    func testMoveGroupResultAndFeedbackPerDistribution() throws {
        var executed = RobotTrajectory()
        executed.jointTrajectory.jointNames = ["panda_joint1"]
        let result = MoveGroupAction.Result(
            errorCode: MoveItErrorCodes(val: MoveItErrorCodes.SUCCESS, message: "ok", source: "move_group"),
            executedTrajectory: executed, planningTime: 0.125)
        for distro in moveGroupDistros {
            try roundTrip(result, distro: distro)
            try roundTrip(MoveGroupAction.Feedback(state: "MONITOR"), distro: distro)
        }
    }

    func testMoveGroupWrappersPerDistribution() throws {
        let goalId = UniqueIdentifierUUID(uuid: Array(0..<16))
        let result = MoveGroupAction.Result(
            errorCode: MoveItErrorCodes(val: MoveItErrorCodes.PLANNING_FAILED), planningTime: 1.5)
        for distro in moveGroupDistros {
            var value = goal
            value.request = expected(value.request, on: distro)
            try roundTrip(MoveGroup_SendGoal_Request(goalId: goalId, goal: value), distro: distro)
            try roundTrip(
                MoveGroup_SendGoal_Response(accepted: true, stamp: Time(sec: 12, nanosec: 345)), distro: distro)
            try roundTrip(MoveGroup_GetResult_Request(goalId: goalId), distro: distro)
            try roundTrip(MoveGroup_GetResult_Response(status: 4, result: result), distro: distro)
            try roundTrip(
                MoveGroup_FeedbackMessage(goalId: goalId, feedback: MoveGroupAction.Feedback(state: "PLANNING")),
                distro: distro)
        }
    }
}
