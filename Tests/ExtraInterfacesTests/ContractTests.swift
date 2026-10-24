import ControlMsgs
import MoveitMsgs
import ObjectRecognitionMsgs
import OctomapMsgs
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

    func testMoveGroupNames() {
        let info = MoveGroupAction.typeInfo
        XCTAssertEqual(info.actionName, "moveit_msgs/action/MoveGroup")
        XCTAssertEqual(MoveGroup_SendGoal_Request.typeInfo.typeName, "moveit_msgs/action/MoveGroup_SendGoal_Request")
        XCTAssertEqual(
            MoveGroup_SendGoal_Response.typeInfo.typeName, "moveit_msgs/action/MoveGroup_SendGoal_Response")
        XCTAssertEqual(
            MoveGroup_GetResult_Request.typeInfo.typeName, "moveit_msgs/action/MoveGroup_GetResult_Request")
        XCTAssertEqual(
            MoveGroup_GetResult_Response.typeInfo.typeName, "moveit_msgs/action/MoveGroup_GetResult_Response")
        XCTAssertEqual(MoveGroup_FeedbackMessage.typeInfo.typeName, "moveit_msgs/action/MoveGroup_FeedbackMessage")
        XCTAssertEqual(MotionPlanRequest.typeInfo.typeName, "moveit_msgs/msg/MotionPlanRequest")
        XCTAssertEqual(PlanningOptions.typeInfo.typeName, "moveit_msgs/msg/PlanningOptions")
        XCTAssertEqual(Constraints.typeInfo.typeName, "moveit_msgs/msg/Constraints")
        XCTAssertEqual(JointConstraint.typeInfo.typeName, "moveit_msgs/msg/JointConstraint")
        XCTAssertEqual(MoveItErrorCodes.typeInfo.typeName, "moveit_msgs/msg/MoveItErrorCodes")
        XCTAssertEqual(ObjectType.typeInfo.typeName, "object_recognition_msgs/msg/ObjectType")
        XCTAssertEqual(Octomap.typeInfo.typeName, "octomap_msgs/msg/Octomap")
        XCTAssertEqual(OctomapWithPose.typeInfo.typeName, "octomap_msgs/msg/OctomapWithPose")
    }

    /// The joint-space goal Conduit sends: one `JointConstraint` per joint, scaling factors and
    /// `planOnly`.
    func testMoveGroupGoalLabels() {
        let joint = JointConstraint(
            jointName: "panda_joint1", position: 0.5, toleranceAbove: 0.01, toleranceBelow: 0.02, weight: 1.0)
        XCTAssertEqual(joint.jointName, "panda_joint1")
        XCTAssertEqual(joint.position, 0.5)
        XCTAssertEqual(joint.toleranceAbove, 0.01)
        XCTAssertEqual(joint.toleranceBelow, 0.02)
        XCTAssertEqual(joint.weight, 1.0)
        let request = MotionPlanRequest(
            goalConstraints: [Constraints(name: "joints", jointConstraints: [joint])],
            pipelineId: "ompl",
            plannerId: "RRTConnect",
            groupName: "panda_arm",
            numPlanningAttempts: 5,
            allowedPlanningTime: 2.5,
            maxVelocityScalingFactor: 0.2,
            maxAccelerationScalingFactor: 0.3,
            smoothnessLevel: 0.5)
        XCTAssertEqual(request.goalConstraints.first?.jointConstraints, [joint])
        XCTAssertEqual(request.pipelineId, "ompl")
        XCTAssertEqual(request.plannerId, "RRTConnect")
        XCTAssertEqual(request.groupName, "panda_arm")
        XCTAssertEqual(request.numPlanningAttempts, 5)
        XCTAssertEqual(request.allowedPlanningTime, 2.5)
        XCTAssertEqual(request.maxVelocityScalingFactor, 0.2)
        XCTAssertEqual(request.maxAccelerationScalingFactor, 0.3)
        XCTAssertEqual(request.smoothnessLevel, 0.5)
        let goal = MoveGroupAction.Goal(request: request, planningOptions: PlanningOptions(planOnly: false))
        XCTAssertEqual(goal.request, request)
        XCTAssertFalse(goal.planningOptions.planOnly)

        let result = MoveGroupAction.Result(
            errorCode: MoveItErrorCodes(val: MoveItErrorCodes.SUCCESS), planningTime: 0.75)
        XCTAssertEqual(result.errorCode.val, MoveItErrorCodes.SUCCESS)
        XCTAssertEqual(result.planningTime, 0.75)
        XCTAssertEqual(result.plannedTrajectory, RobotTrajectory())
        XCTAssertEqual(result.executedTrajectory, RobotTrajectory())
        XCTAssertEqual(result.trajectoryStart, RobotState())
        XCTAssertEqual(MoveGroupAction.Feedback(state: "PLANNING").state, "PLANNING")
    }

    func testMoveItErrorCodesConstants() {
        XCTAssertEqual(MoveItErrorCodes.UNDEFINED, 0)
        XCTAssertEqual(MoveItErrorCodes.SUCCESS, 1)
        XCTAssertEqual(MoveItErrorCodes.FAILURE, 99999)
        XCTAssertEqual(MoveItErrorCodes.PLANNING_FAILED, -1)
        XCTAssertEqual(MoveItErrorCodes.INVALID_MOTION_PLAN, -2)
        XCTAssertEqual(MoveItErrorCodes.CONTROL_FAILED, -4)
        XCTAssertEqual(MoveItErrorCodes.TIMED_OUT, -6)
        XCTAssertEqual(MoveItErrorCodes.PREEMPTED, -7)
        XCTAssertEqual(MoveItErrorCodes.START_STATE_IN_COLLISION, -10)
        XCTAssertEqual(MoveItErrorCodes.GOAL_IN_COLLISION, -12)
        XCTAssertEqual(MoveItErrorCodes.GOAL_CONSTRAINTS_VIOLATED, -14)
        XCTAssertEqual(MoveItErrorCodes.INVALID_GROUP_NAME, -15)
        XCTAssertEqual(MoveItErrorCodes.INVALID_GOAL_CONSTRAINTS, -16)
        XCTAssertEqual(MoveItErrorCodes.NO_IK_SOLUTION, -31)
    }
}
