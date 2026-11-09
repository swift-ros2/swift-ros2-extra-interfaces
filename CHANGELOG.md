# Changelog

## 1.2.0 - 2026-11-09

The Nav2 `NavigateToPose` action; see 1.2.0-rc.1 below. The generated code is the same as
1.2.0-rc.1. It needs swift-ros2-rosidl 1.2.0 (`from: "1.2.0"`); send these types with swift-ros2
3.1.0 or later (`from: "3.1.0"`). Conduit 3.0, built against 1.2.0-rc.1 and swift-ros2 3.1.1,
sends `NavigateToPose` goals to Nav2 on a ROS 2 Jazzy host and reads their outcomes, including
canceled goals and a goal that replaces one still driving.

Checked live: 1.2.0-rc.1, through swift-ros2 3.1.1's `ROS2ActionClient` and swift-ros2-rosidl
1.2.0, sends `NavigateToPose` goals from macOS to an rclpy action server on ROS 2 Humble, Jazzy,
Kilted and Lyrical hosts (nav2_msgs 1.1.20, 1.3.13, 1.4.2 and 1.5.2) over both the wire Zenoh and
the wire DDS transports. On each, one goal succeeds with every feedback message decoded, Lyrical's
`positionTrackingError` and `headingTrackingError` included, and its result's `errorCode` and
`errorMsg` read (`0` and `""` from Humble's `std_msgs/Empty` result); a second goal is canceled by
its goal id and ends CANCELED. The Jazzy, Kilted and Lyrical hosts report the feedback topic with
the type hash `NavigateToPose_FeedbackMessage.typeInfo(for:)` gives: one hash on Jazzy and Kilted,
another on Lyrical.

## 1.2.0-rc.1

Release candidate for 1.2.0: the Nav2 `NavigateToPose` action. Until 1.2.0, depend on it with
`exact: "1.2.0-rc.1"`; `from: "1.2.0"` resolves only once 1.2.0 is tagged. Send these types with
swift-ros2 3.1.0 or later (`from: "3.1.0"`), which uses the layout and hash of the context's
distribution.

### Added

- New module `Nav2Msgs`: `nav2_msgs/action/NavigateToPose` (`NavigateToPoseAction`, with `Goal`,
  `Result`, `Feedback` and the SendGoal / GetResult / FeedbackMessage wrappers). Generated from
  navigation2 1.1.20 (Humble), 1.3.14 (Jazzy), 1.4.2 (Kilted) and 1.5.3 (Lyrical), the release
  tags rosdistro lists, pinned in `idl.lock`; Rolling uses the Lyrical layout.
- The layout differs by distribution, and each field is encoded only for the distributions that
  have it:
  - The goal (`pose`, `behaviorTree`) is the same everywhere.
  - Humble's result is one `std_msgs/Empty result`. Jazzy and later have `errorCode` (`uint16`)
    and `errorMsg` (`string`), which decode as `0` and `""` on Humble.
  - The result constants grow per release: `NONE` from Jazzy; `UNKNOWN`,
    `FAILED_TO_LOAD_BEHAVIOR_TREE`, `TF_ERROR` and `TIMEOUT` from Kilted; `GOAL_REJECTED` and
    `SEND_GOAL_FAILURE` from Lyrical. `NavigateToPoseAction.Result` has all seven.
  - Lyrical's feedback adds `positionTrackingError` and `headingTrackingError` (`float32`), 8
    bytes after `distanceRemaining`; they decode as `0.0` on Humble, Jazzy and Kilted.
- The goal, the result and the SendGoal and GetResult types have one type hash on Jazzy, Kilted
  and Lyrical. `NavigateToPoseAction.Feedback` and `NavigateToPose_FeedbackMessage` have one
  hash on Jazzy and Kilted and another on Lyrical and Rolling, from `typeInfo(for:)`; the action
  itself has no hash of its own: `NavigateToPoseAction.typeInfo(for:)` returns an
  `ROS2ActionTypeInfo` with one hash per type (goal, result, feedback, the wrappers and the two
  services). Humble has no type hashes.

### Changed

- The oracles install `ros-<distro>-nav2-msgs`.
- `Nav2Msgs` is generated with the `swift-ros2-gen` of swift-ros2-rosidl 1.2.0, which merges an
  action that differs between distributions. Requires swift-ros2-rosidl 1.2.0 (`from: "1.2.0"`),
  and the oracle workflow runs its `interface-oracles.yml@1.2.0`. The other modules are
  unchanged.

### Known gaps

- navigation2 has no Rolling release, so `ros-rolling-nav2-msgs` does not exist and the weekly
  Rolling oracle run cannot install it. A per-distribution exclusion is a follow-up.

## 1.1.0 - 2026-10-29

The MoveGroup action and the types it reaches; see 1.1.0-rc.1 below. The generated code is the
same as 1.1.0-rc.1. Send these types with swift-ros2 3.1.0 or later (`from: "3.1.0"`). Conduit 3.0,
built against 1.1.0-rc.1 and swift-ros2 3.1.0-rc.1, sends MoveGroup goals to `move_group` on a
ROS 2 Jazzy host and reads their outcomes, including canceled goals and MoveIt error codes.

## 1.1.0-rc.1

Release candidate for 1.1.0: the MoveGroup action and the types it reaches. Until 1.1.0, depend
on it with `exact: "1.1.0-rc.1"`; `from: "1.1.0"` resolves only once 1.1.0 is tagged. Send these
types with swift-ros2 3.1.0-rc.1 (`exact: "3.1.0-rc.1"`) until swift-ros2 3.1.0 is tagged.

### Added

- `MoveitMsgs`: `moveit_msgs/action/MoveGroup` (`MoveGroupAction`, with `Goal`, `Result`,
  `Feedback` and the SendGoal / GetResult / FeedbackMessage wrappers) and the 26 `moveit_msgs`
  messages it reaches, among them `MotionPlanRequest`, `PlanningOptions`, `Constraints`,
  `JointConstraint`, `RobotState`, `RobotTrajectory`, `PlanningScene` and `MoveItErrorCodes`.
  Generated from the Jazzy (2.6.0), Kilted (2.7.1) and Lyrical (2.7.2) IDL; no Humble.
- New modules `ObjectRecognitionMsgs` (`object_recognition_msgs/msg/ObjectType`) and
  `OctomapMsgs` (`octomap_msgs/msg/Octomap`, `OctomapWithPose`), for the types `moveit_msgs`
  uses, generated from object_recognition_msgs 2.0.0 and octomap_msgs 2.0.1.
- `MotionPlanRequest.smoothnessLevel` (Lyrical's `smoothness_level`) is encoded only for Lyrical
  and later and decodes as `0.0` on Jazzy and Kilted. `MotionPlanRequest`,
  `MoveGroupAction.Goal`, `MoveGroup_SendGoal_Request` and the SendGoal service have one type
  hash on Jazzy and Kilted and another on Lyrical and Rolling, from `typeInfo(for:)`.

### Changed

- Depends on swift-ros2-common-interfaces (`from: "1.0.0"`) for the standard types the MoveGroup
  types hold. `idl.lock` pins `common_interfaces` at the commits swift-ros2-common-interfaces
  generates from, plus `object_recognition_msgs` and `octomap_msgs` at their rosdistro release
  tags.
- Programs that send these types with swift-ros2 need swift-ros2 3.1.0 or later, which sends the
  layout and hash of the context's distribution. With 3.0.x, a MoveGroup goal goes out with the
  Jazzy layout and hash on Lyrical, and Lyrical's `move_group` does not take it.
- The CI lint step skips the generated oracle samples, whose generated lines can exceed the line
  length; the drift check still covers them.
- Requires swift-ros2-rosidl 1.1.1 (`from: "1.1.1"`), and the oracle workflow runs its
  `interface-oracles.yml@1.1.1`. The generated types are unchanged. The oracle corpus encodes
  the samples of a distribution with that distribution's message schemas
  (`OracleSamples.samples(for:)`) and round-trips them as well as the default set.

## 1.0.0 - 2026-10-17

First stable release; the public API is now covered by semantic versioning. The generated code is
the same as 1.0.0-rc.1, and the package still depends only on swift-ros2-rosidl (`from: "1.0.0"`;
CI and the oracles run against 1.0.1, which changes no package code).

1.0.0-rc.1 passed live interop through swift-ros2 against ROS 2 Humble, Jazzy, Kilted and Lyrical
hosts over both the wire Zenoh and the wire DDS transports:

- messages in both directions;
- the `ServoCommandType` service as client and as server;
- the `GripperCommand` action as client and as server;
- on Jazzy, Kilted and Lyrical, all 15 type hashes equal the host's type descriptions. Humble has
  only `GripperCommand` and no type hashes.

The RCL transports report `TransportError.unsupportedFeature` cleanly for the services and actions
of these types, since there is no bundled type support; RCL DDS topics work through the raw-CDR
fallback. A fresh-package README walkthrough also passed.

## 1.0.0-rc.1

First release candidate. Until 1.0.0, depend on it with `exact: "1.0.0-rc.1"`; `from: "1.0.0"` resolves only once 1.0.0 is tagged.

- `ControlMsgs`: `control_msgs/msg/GripperCommand` and `control_msgs/action/GripperCommand`
  (`GripperCommandAction`), generated from the Humble, Jazzy, Kilted and Lyrical IDL.
- `MoveitMsgs`: `moveit_msgs/msg/ServoStatus` and `moveit_msgs/srv/ServoCommandType`
  (`ServoCommandTypeSrv`), generated from the Jazzy, Kilted and Lyrical IDL; Humble's
  `moveit_msgs` has neither interface.
- Generated by the `swift-ros2-gen` of swift-ros2-rosidl 1.0.1. `idl.lock` pins `control_msgs`
  and `moveit_msgs` at the release tag rosdistro lists for each distribution, plus
  `rcl_interfaces` and `unique_identifier_msgs` for the types that live in swift-ros2-rosidl.
- Depends only on swift-ros2-rosidl; no binary framework and no IDL is downloaded.
- Tests pin the ROS names, field labels and constants of every type, their CDR round trip and
  their distribution shapes.
- CI builds on macOS, Linux, Windows and Android, builds DocC, fails when the committed sources
  differ from `idl.lock`, checks that consumers download no binaries and compares the public API
  with the latest 1.x release. The oracle workflow checks every RIHS01 hash and CDR sample
  against the real ROS 2 packages on Jazzy and Lyrical for every pull request, and on Kilted and
  Rolling weekly.
