#!/usr/bin/env bash
# Prints the swift-ros2-gen arguments for this repository, one per line, reading the IDL that
# Scripts/fetch-idl.sh put in .idl/. Read by Scripts/regenerate.sh and by swift-ros2-rosidl's
# interface-oracles.yml.
#   generator-args.sh             every generated distribution (Scripts/regenerate.sh)
#   generator-args.sh <distro>    only <distro>, labelled @<distro> (the oracle matrix);
#                                 rolling reads the Lyrical IDL
set -euo pipefail
# The interfaces this package holds, by file stem. One list for every --input package: the
# generator parses only these files, so the rest of moveit_msgs (and its octomap_msgs /
# object_recognition_msgs references) is never read. No stem may exist in both packages.
TYPES="GripperCommand,ServoCommandType,ServoStatus"
DISTROS=${1:-"humble jazzy kilted lyrical"}
printf -- '--types\n%s\n' "$TYPES"
for distro in $DISTROS; do
  src=$distro
  [ "$distro" = rolling ] && src=lyrical
  printf -- '--input\ncontrol_msgs=.idl/control_msgs-%s/control_msgs@%s\n' "$src" "$distro"
  # moveit_msgs has the Servo interfaces from Jazzy (2.6.0) on; Humble's 2.2.3 has neither.
  if [ "$src" != humble ]; then
    printf -- '--input\nmoveit_msgs=.idl/moveit_msgs-%s@%s\n' "$src" "$distro"
  fi
  # Types that live in swift-ros2-rosidl: referenced and hashed, not emitted here. Generated
  # action wrappers use unique_identifier_msgs/UUID and builtin_interfaces/Time only.
  printf -- '--dependency\nbuiltin_interfaces=.idl/rcl_interfaces-%s/builtin_interfaces@%s\n' "$src" "$distro"
  printf -- '--dependency\nunique_identifier_msgs=.idl/unique_identifier_msgs-%s@%s\n' "$src" "$distro"
done
