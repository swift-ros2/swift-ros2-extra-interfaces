import ControlMsgs
import MoveitMsgs
import ObjectRecognitionMsgs
import OctomapMsgs
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

    // MARK: - MoveGroup

    private let jazzyMotionPlanRequest = "RIHS01_f82ed20da5f8f93146999c1a3cfe34b56b97fc10333b40cac69782a1210888d7"
    private let lyricalMotionPlanRequest = "RIHS01_af341d1ccabbd5f0303a6b8605cf5fb3422792c7641cc5b6e80b2d5b8458f324"

    /// Lyrical's moveit_msgs 2.7.2 adds `smoothness_level`: Jazzy and Kilted share one hash, Lyrical
    /// and Rolling (which takes the Lyrical shape) another, and Humble has none.
    func testMotionPlanRequestHashPerDistribution() {
        XCTAssertEqual(MotionPlanRequest.typeInfo(for: .jazzy).typeHash, jazzyMotionPlanRequest)
        XCTAssertEqual(MotionPlanRequest.typeInfo(for: .kilted).typeHash, jazzyMotionPlanRequest)
        XCTAssertEqual(MotionPlanRequest.typeInfo(for: .lyrical).typeHash, lyricalMotionPlanRequest)
        XCTAssertEqual(MotionPlanRequest.typeInfo(for: .rolling).typeHash, lyricalMotionPlanRequest)
        XCTAssertNil(MotionPlanRequest.typeInfo(for: .humble).typeHash)
        XCTAssertEqual(MotionPlanRequest.typeInfo.typeHash, jazzyMotionPlanRequest)
        for distro in ROS2Distro.allCases {
            XCTAssertEqual(MotionPlanRequest.typeInfo(for: distro).typeName, "moveit_msgs/msg/MotionPlanRequest")
        }
    }

    func testMoveGroupSendGoalRequestHashPerDistribution() {
        let jazzy = "RIHS01_02e8af2a61d8fe3044deddcbdffd536e96c2d822e64338c49397798ea665ac90"
        let lyrical = "RIHS01_4f63c071f84e4a35c968e2780188f85782ce46ed008c157148ff694e64aac59b"
        XCTAssertEqual(MoveGroup_SendGoal_Request.typeInfo(for: .jazzy).typeHash, jazzy)
        XCTAssertEqual(MoveGroup_SendGoal_Request.typeInfo(for: .kilted).typeHash, jazzy)
        XCTAssertEqual(MoveGroup_SendGoal_Request.typeInfo(for: .lyrical).typeHash, lyrical)
        XCTAssertEqual(MoveGroup_SendGoal_Request.typeInfo(for: .rolling).typeHash, lyrical)
        XCTAssertNil(MoveGroup_SendGoal_Request.typeInfo(for: .humble).typeHash)
    }

    /// The goal, the SendGoal request and the SendGoal service change with `MotionPlanRequest`; the
    /// result, the feedback and the GetResult service do not.
    func testMoveGroupActionTypeInfoPerDistribution() {
        let jazzy = MoveGroupAction.typeInfo(for: .jazzy)
        let lyrical = MoveGroupAction.typeInfo(for: .lyrical)
        for distro in [ROS2Distro.jazzy, .kilted] {
            let info = MoveGroupAction.typeInfo(for: distro)
            XCTAssertEqual(
                info.goalTypeHash, "RIHS01_c2a80a3f1ae1a97fb8c6e7ff35da28d7dd161f64683474801ed4371e4fd220ce")
            XCTAssertEqual(
                info.sendGoalRequestTypeHash,
                "RIHS01_02e8af2a61d8fe3044deddcbdffd536e96c2d822e64338c49397798ea665ac90")
            XCTAssertEqual(
                info.sendGoalServiceTypeHash,
                "RIHS01_e2964f7aac611dc92a76e7b3e925a2d9e039d4f70ef348af0dbe36e8f3274527")
        }
        for distro in [ROS2Distro.lyrical, .rolling] {
            let info = MoveGroupAction.typeInfo(for: distro)
            XCTAssertEqual(
                info.goalTypeHash, "RIHS01_3e6f85f75c3bc7617dd01256f6d9b936e8c8d9965cbcfb41ff109a53e2bc3633")
            XCTAssertEqual(
                info.sendGoalRequestTypeHash,
                "RIHS01_4f63c071f84e4a35c968e2780188f85782ce46ed008c157148ff694e64aac59b")
            XCTAssertEqual(
                info.sendGoalServiceTypeHash,
                "RIHS01_e153a193f297fef004a7d6409f782f48d46ce1223587279ee531ee5874c77611")
        }
        for distro in [ROS2Distro.jazzy, .kilted, .lyrical, .rolling] {
            let info = MoveGroupAction.typeInfo(for: distro)
            XCTAssertEqual(info.actionName, "moveit_msgs/action/MoveGroup")
            XCTAssertEqual(
                info.resultTypeHash, "RIHS01_188b11f0cf9d62360f554ae9a3f55cb9162767be782a7e05ee6a66371f262ebe")
            XCTAssertEqual(
                info.feedbackTypeHash, "RIHS01_d0cb5a6d2213e97858a73830b26b1c8f1d8989b6b47c489886527a419452fafe")
            XCTAssertEqual(
                info.sendGoalResponseTypeHash,
                "RIHS01_53b2e441aac2e196a87222d1f9f64c0745f4288d1b967826993d6a35edeceaab")
            XCTAssertEqual(
                info.getResultRequestTypeHash,
                "RIHS01_3d618f3ef553f48620196cb9586ab1012cc219c597a409bba860f6a23b8743a4")
            XCTAssertEqual(
                info.getResultResponseTypeHash,
                "RIHS01_c13439db4b8be0a7056e604be863d5f4b6265cdb64887e26e12cfa5622c58682")
            XCTAssertEqual(
                info.feedbackMessageTypeHash,
                "RIHS01_c5b66e44e3b976db5536bf3eb773d83238c1d1d8c53ccaa7ccba28fad55fa352")
            XCTAssertEqual(
                info.getResultServiceTypeHash,
                "RIHS01_730c808018e9f6d10ae073e3a7e9da365e791fe5a461c6fe269af927437969fa")
        }
        XCTAssertEqual(MoveGroupAction.typeInfo.goalTypeHash, jazzy.goalTypeHash)
        XCTAssertNotEqual(jazzy.goalTypeHash, lyrical.goalTypeHash)
        let humble = MoveGroupAction.typeInfo(for: .humble)
        XCTAssertEqual(humble.actionName, "moveit_msgs/action/MoveGroup")
        XCTAssertNil(humble.goalTypeHash)
        XCTAssertNil(humble.sendGoalServiceTypeHash)
    }

    /// Types of the closure that are the same on every distribution, one per module.
    func testMoveGroupClosureTypeHashes() {
        XCTAssertEqual(
            JointConstraint.typeInfo.typeHash,
            "RIHS01_4996641a8e12f5b7fde07f1cec1490324e1c4035ac5fc989ce99c9600c31e30d")
        XCTAssertEqual(
            Constraints.typeInfo.typeHash, "RIHS01_71718200459ae8fecdc4f2c9631215f7eba5ff686c701a32e231ba8b11b3592b")
        XCTAssertEqual(
            PlanningOptions.typeInfo.typeHash,
            "RIHS01_2570a8ed681162d1d3afbce3a8e7ff2b6fd519676d13cf952e0a388072b255db")
        XCTAssertEqual(
            MoveItErrorCodes.typeInfo.typeHash,
            "RIHS01_dcda8a9950cf6dd6ac221c2c0d2509f52f136afa0403dd19beacdf07e83e4a07")
        XCTAssertEqual(
            RobotState.typeInfo.typeHash, "RIHS01_7c516dc15713e545cb2836c5ca745fbdcfcc10de4855a41c83e6b4bf1afc3f83")
        XCTAssertEqual(
            ObjectType.typeInfo.typeHash, "RIHS01_5eb3ee3976403366d7c50d7dbee8bec96b3bced1e752674a7194a35841632134")
        XCTAssertEqual(
            Octomap.typeInfo.typeHash, "RIHS01_9891a19a05b70ec20aa8f45db3f8300b9ab80afff32c61c549d25087da9625b0")
        XCTAssertEqual(
            OctomapWithPose.typeInfo.typeHash,
            "RIHS01_e65f8760aa96a2acef86b6d206175cfc78420082b6159dd3fa6ebf93f5f81979")
    }

    private func encoded<T: CDRCodable>(_ value: T, distro: ROS2Distro) throws -> Data {
        let encoder = CDREncoder(distro: distro)
        encoder.writeEncapsulationHeader()
        try value.encode(to: encoder)
        return encoder.getData()
    }

    /// `smoothness_level` is written only for Lyrical and later, as the last float64 (8 bytes, already
    /// aligned after `max_cartesian_speed`), and decodes as 0 where it is absent.
    func testSmoothnessLevelOnlyOnLyricalAndLater() throws {
        let request = MotionPlanRequest(
            groupName: "panda_arm", maxCartesianSpeed: 0.25, smoothnessLevel: 0.5)
        let jazzy = try encoded(request, distro: .jazzy)
        XCTAssertEqual(try encoded(request, distro: .kilted), jazzy)
        let lyrical = try encoded(request, distro: .lyrical)
        XCTAssertEqual(try encoded(request, distro: .rolling), lyrical)
        XCTAssertEqual(lyrical.count, jazzy.count + 8)
        XCTAssertEqual(lyrical.prefix(jazzy.count), jazzy)
        var expected = Double(0.5).bitPattern.littleEndian
        XCTAssertEqual(lyrical.suffix(8), Data(bytes: &expected, count: 8))

        let fromJazzy = try MotionPlanRequest(from: CDRDecoder(data: jazzy, distro: .jazzy))
        XCTAssertEqual(fromJazzy.smoothnessLevel, 0)
        XCTAssertEqual(fromJazzy.maxCartesianSpeed, 0.25)
        let fromLyrical = try MotionPlanRequest(from: CDRDecoder(data: lyrical, distro: .lyrical))
        XCTAssertEqual(fromLyrical, request)
    }

    /// The nested `MotionPlanRequest` writes through the goal's encoder, so the goal and the
    /// SendGoal request carry the same 8-byte difference.
    func testMoveGroupGoalCarriesTheDistributionShape() throws {
        let goal = MoveGroupAction.Goal(request: MotionPlanRequest(groupName: "panda_arm", smoothnessLevel: 0.5))
        XCTAssertEqual(try encoded(goal, distro: .lyrical).count, try encoded(goal, distro: .jazzy).count + 8)
        let request = MoveGroup_SendGoal_Request(goal: goal)
        XCTAssertEqual(try encoded(request, distro: .lyrical).count, try encoded(request, distro: .jazzy).count + 8)
    }
}
