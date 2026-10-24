#!/usr/bin/env bash
# Prints the swift-ros2-gen arguments for this repository, one per line, reading the IDL that
# Scripts/fetch-idl.sh put in .idl/. Read by Scripts/regenerate.sh and by swift-ros2-rosidl's
# interface-oracles.yml.
#   generator-args.sh             every generated distribution (Scripts/regenerate.sh)
#   generator-args.sh <distro>    only <distro>, labelled @<distro> (the oracle matrix);
#                                 rolling reads the Lyrical IDL
set -euo pipefail
# The interfaces this package holds, by file stem. One list for every --input package: the
# generator parses only these files, so the rest of each package is never read. No stem may
# exist in two packages.
#   control_msgs:            GripperCommand (message and action)
#   moveit_msgs:             ServoCommandType, ServoStatus, the MoveGroup action and every
#                            moveit_msgs message it reaches
#   object_recognition_msgs: ObjectType (reached from CollisionObject)
#   octomap_msgs:            Octomap, OctomapWithPose (reached from PlanningSceneWorld)
TYPES="GripperCommand,ServoCommandType,ServoStatus"
TYPES+=",MoveGroup,AllowedCollisionEntry,AllowedCollisionMatrix,AttachedCollisionObject"
TYPES+=",BoundingVolume,CartesianPoint,CartesianTrajectory,CartesianTrajectoryPoint"
TYPES+=",CollisionObject,Constraints,GenericTrajectory,JointConstraint,LinkPadding,LinkScale"
TYPES+=",MotionPlanRequest,MoveItErrorCodes,ObjectColor,OrientationConstraint,PlanningOptions"
TYPES+=",PlanningScene,PlanningSceneWorld,PositionConstraint,RobotState,RobotTrajectory"
TYPES+=",TrajectoryConstraints,VisibilityConstraint,WorkspaceParameters"
TYPES+=",ObjectType,Octomap,OctomapWithPose"
# common_interfaces packages the moveit_msgs types reference, transitively. They live in
# swift-ros2-common-interfaces: referenced and hashed, not emitted here.
COMMON="std_msgs geometry_msgs sensor_msgs shape_msgs trajectory_msgs"
DISTROS=${1:-"humble jazzy kilted lyrical"}
printf -- '--types\n%s\n' "$TYPES"
for distro in $DISTROS; do
  src=$distro
  [ "$distro" = rolling ] && src=lyrical
  printf -- '--input\ncontrol_msgs=.idl/control_msgs-%s/control_msgs@%s\n' "$src" "$distro"
  # moveit_msgs has the Servo interfaces from Jazzy (2.6.0) on; Humble's 2.2.3 has neither,
  # and the MoveGroup closure is generated for the same distributions.
  if [ "$src" != humble ]; then
    printf -- '--input\nmoveit_msgs=.idl/moveit_msgs-%s@%s\n' "$src" "$distro"
    printf -- '--input\nobject_recognition_msgs=.idl/object_recognition_msgs-%s@%s\n' "$src" "$distro"
    printf -- '--input\noctomap_msgs=.idl/octomap_msgs-%s@%s\n' "$src" "$distro"
  fi
  # Passed for every distribution swift-ros2-common-interfaces is generated from (Humble
  # included), so the hashes here include the same dependency IDL as the types there.
  for pkg in $COMMON; do
    printf -- '--dependency\n%s=.idl/common_interfaces-%s/%s@%s\n' "$pkg" "$src" "$pkg" "$distro"
  done
  # Types that live in swift-ros2-rosidl: referenced and hashed, not emitted here. Generated
  # action wrappers use unique_identifier_msgs/UUID and builtin_interfaces/Time only.
  printf -- '--dependency\nbuiltin_interfaces=.idl/rcl_interfaces-%s/builtin_interfaces@%s\n' "$src" "$distro"
  printf -- '--dependency\nunique_identifier_msgs=.idl/unique_identifier_msgs-%s@%s\n' "$src" "$distro"
done
