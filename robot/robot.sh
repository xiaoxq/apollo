#!/usr/bin/env bash

######################################################################## Prepare

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ); pwd )
cd "$DIR/.."

BRANCH=robot
git checkout -b ${BRANCH} upstream/master || git checkout ${BRANCH}

git remote update
git reset --hard upstream/master

set -e

TEXT_FILES=$(find . -type f | \
             grep -v '\.git' | \
             grep -v 'aaron_robot' | \
             grep -v 'modules/dreamview/frontend/dist' | \
             grep -v 'third_party/' | \
             grep -v 'txt$' | \
    xargs file | grep 'ASCII text' | awk -F: '{print $1}')
CPP_FILES=$(find cyber/ modules/ -type f | grep -e "\.cc$" -e "\.h$")
CHANGED="no"

echo "Found TEXT_FILES: $(echo "${TEXT_FILES}" | wc -l)"
echo "Found CPP_FILES: $(echo "${CPP_FILES}" | wc -l)"

################################################################################
find cyber/ modules/ third_party/ | grep 'BUILD$' | xargs -L 1 ./scripts/buildifier.sh

echo "Buildifier: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Refactor BUILD files."
  CHANGED="yes"
fi
################################################################################
echo "${TEXT_FILES}" | grep "\.proto$" | xargs -L 1 ./scripts/clang-format.sh

echo "Proto clang-format: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Format proto files."
  CHANGED="yes"
fi
################################################################################
echo "${TEXT_FILES}" | \
    grep -v "*/BUILD" | \
    grep -v "vscode/" | \
    grep -v "cyber/*\.cc" | \
    grep -v "cyber/*\.h" | \
    grep -v "modules/*\.cc" | \
    grep -v "modules/*\.h" | \
    grep -v "\.seg$" | \
    grep -v "\.txt$" | \
    xargs sed -i 's/[ \t]*$//'

echo "Trailing spaces: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Remove trailing spaces."
  CHANGED="yes"
fi
################################################################################
echo "${CPP_FILES}" | xargs sed -i 's/ ? true : false//g'

echo "? true : false: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Remove unnecessary conditional operator."
  CHANGED="yes"
fi
################################################################################
echo "${CPP_FILES}" | xargs sed -i 's/\.size() <= 0/.empty()/g'
echo "${CPP_FILES}" | xargs sed -i 's/_size() <= 0/().empty()/g'
echo "${CPP_FILES}" | xargs sed -i 's/\.size() == 0/.empty()/g'
echo "${CPP_FILES}" | \
    grep -v modules/prediction/container/obstacles/obstacle.cc | \
    grep -v modules/prediction/evaluator/evaluator_manager.cc | \
    grep -v modules/prediction/evaluator/vehicle/junction_mlp_evaluator.cc | \
    grep -v modules/prediction/predictor/predictor.cc | \
    grep -v modules/prediction/scenario/prioritization/obstacles_prioritizer.cc | \
    xargs sed -i 's/_size() == 0/().empty()/g'

echo ".size() == 0: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Check empty container by API."
  CHANGED="yes"
fi
################################################################################
echo "${CPP_FILES}" | grep -v modules/drivers | xargs sed -i "s/ NULL)/ nullptr)/g"
echo "${CPP_FILES}" | grep -v modules/drivers | xargs sed -i "s/ NULL;/ nullptr;/g"

echo "nullptr: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Migrate NULL to nullptr."
  CHANGED="yes"
fi
################################################################################
echo "${TEXT_FILES}" | \
    grep -v cyber/logger/logger_util.h | \
    grep -v cyber/tools/cyber_channel/cyber_channel | \
    grep -v cyber/tools/cyber_tools_auto_complete.bash | \
    grep -v docker/setup_host/etc/udev | \
    grep -v modules/common/time/time_util.h | \
    grep -v modules/dreamview/frontend | \
    grep -v modules/drivers/camera/usb_cam.cc | \
    grep -v modules/drivers/gnss/third_party/rtklib.h | \
    grep -v modules/drivers/velodyne/parser/velodyne_parser.h | \
    grep -v modules/perception/common/i_lib/geometry/i_util.h | \
    grep -v modules/perception/fusion/lib/data_association/hm_data_association | \
    grep -v modules/perception/lib/utils/time_util.h | \
    grep -v modules/perception/lib/utils/timer.cc | \
    grep -v modules/perception/lidar/lib/segmentation/ncut | \
    grep -v modules/planning/common/path/discretized_path.cc | \
    grep -v modules/planning/common/path/frenet_frame_path.cc | \
    grep -v modules/planning/common/speed/speed_data.cc | \
    grep -v modules/planning/common/trajectory/discretized_trajectory.cc | \
    grep -v '/third_party/' | \
    xargs /usr/local/bin/topy -a
echo "${TEXT_FILES}" | xargs -L 1 python3 ${DIR}/typo-fixer.py | bash

echo "typo: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Fix typos."
  CHANGED="yes"
fi
################################################################################
FILES=$( echo "${CPP_FILES}" | grep -v modules/drivers | \
                               grep -v modules/perception | \
                               grep -v modules/localization )
echo "${FILES}" | xargs sed -i "s/const int& /const int /g"
echo "${FILES}" | xargs sed -i "s/const double& /const double /g"
echo "${FILES}" | xargs sed -i "s/const float& /const float /g"
echo "${FILES}" | xargs sed -i "s/const bool& /const bool /g"
echo "${FILES}" | xargs sed -i "s/const size_t& /const size_t /g"
echo "${FILES}" | xargs sed -i "s/const char& /const char /g"

echo "Scalar reference: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Migrate scalar references to values."
  CHANGED="yes"
fi
################################################################################
echo "${CPP_FILES}" | grep -v modules/perception/common/graph/graph_segmentor_test.cc | \
    xargs sed -i -E "s/EXPECT_FALSE(.+) < (.*)/EXPECT_GE\1, \2/g"
echo "${CPP_FILES}" | grep -v modules/perception/camera/test/camera_lib_obstacle_tracker_omt_frame_list_test.cc | \
                      grep -v modules/bridge/common/bridge_buffer_test.cc | \
    xargs sed -i -E "s/EXPECT_TRUE(.+) ==(.*)/EXPECT_EQ\1,\2/g"
echo "${CPP_FILES}" | grep -v cyber/service_discovery/container/graph_test.cc | \
                      grep -v cyber/transport/message/message_test.cc | \
                      grep -v modules/bridge/common/bridge_buffer_test.cc | \
    xargs sed -i -E "s/EXPECT_FALSE(.+) ==(.*)/EXPECT_NE\1,\2/g"
echo "${CPP_FILES}" | grep -v modules/dreamview/backend/simulation_world/simulation_world_service_test.cc | \
    xargs sed -i -E "s/EXPECT_TRUE(.+) < (.*)/EXPECT_LT\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i -E "s/EXPECT_TRUE(.+) !=(.*)/EXPECT_NE\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i -E "s/EXPECT_TRUE(.+) >(.*)/EXPECT_GT\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i -E "s/EXPECT_TRUE(.+) >=(.*)/EXPECT_GE\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i -E "s/EXPECT_TRUE(.+) <=(.*)/EXPECT_LE\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i -E "s/EXPECT_FALSE(.+) !=(.*)/EXPECT_EQ\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i -E "s/EXPECT_FALSE(.+) >(.*)/EXPECT_LE\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i -E "s/EXPECT_FALSE(.+) >=(.*)/EXPECT_LT\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i -E "s/EXPECT_FALSE(.+) <=(.*)/EXPECT_GT\1,\2/g"
echo "${CPP_FILES}" | xargs sed -i 's/EXPECT_TRUE(!/EXPECT_FALSE(/g'
echo "${CPP_FILES}" | xargs sed -i 's/EXPECT_FALSE(!/EXPECT_TRUE(/g'

echo "GTest: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Refactor GTest usage."
  CHANGED="yes"
fi
################################################################################
echo "${CPP_FILES}" |
    grep -v cyber/class_loader/class_loader_register_macro.h | \
    grep -v modules/drivers/camera/usb_cam.cc | \
    grep -v modules/localization/msf/local_pyramid_map/base_map/base_map_config.cc | \
    grep -v modules/localization/ndt/ndt_locator/lidar_locator_ndt.h | \
    grep -v modules/perception/camera/lib/lane/common/common_functions.h | \
    grep -v modules/perception/camera/lib/lane/postprocessor/darkSCNN/darkSCNN_lane_postprocessor.cc | \
    grep -v modules/perception/camera/tools/offline/visualizer.cc | \
    grep -v modules/perception/camera/tools/offline/visualizer.h | \
    grep -v modules/perception/tool/benchmark/lidar/ctpl/ctpl.h | \
    grep -v modules/planning/scenarios/stage_intersection_cruise_impl.cc | \
    grep -v modules/planning/scenarios/stop_sign/unprotected/stage_pre_stop.cc | \
    grep -v modules/planning/scenarios/stop_sign/unprotected/stage_stop.cc | \
    grep -v modules/planning/tasks/task_factory.cc | \
    grep -v modules/planning/traffic_rules/crosswalk.cc | \
    grep -v modules/planning/traffic_rules/stop_sign.cc | \
    grep -v modules/planning/traffic_rules/traffic_light.cc | \
    grep -v modules/prediction/container/obstacles/obstacle.cc | \
    grep -v modules/prediction/predictor/interaction/interaction_predictor.cc | \
    xargs -L 1 python ${DIR}/scope-fixer.py

echo "Scope: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Fix missing name scope brackets."
  CHANGED="yes"
fi
################################################################################
echo "${CPP_FILES}" | \
    grep -v modules/perception/lidar/lib/object_filter_bank/object_filter_bank_test.cc | \
    grep -v modules/perception/lidar/lib/scene_manager/scene_manager_test.cc | \
    xargs sed -i "/^  return;/d"

echo "Return: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Remove unnecessary returns."
  CHANGED="yes"
fi
################################################################################
echo "${CPP_FILES}" | \
    grep -v cyber/class_loader/class_loader_register_macro.h | \
    grep -v modules/drivers/camera/usb_cam.cc | \
    grep -v modules/localization/msf/local_pyramid_map/base_map/base_map_config.cc | \
    grep -v modules/localization/ndt/ndt_locator/lidar_locator_ndt.h | \
    grep -v modules/perception/camera/lib/lane/common/common_functions.h | \
    grep -v modules/perception/camera/lib/lane/postprocessor/darkSCNN/darkSCNN_lane_postprocessor.cc | \
    grep -v modules/perception/camera/tools/offline/visualizer.cc | \
    grep -v modules/perception/camera/tools/offline/visualizer.h | \
    grep -v modules/perception/tool/benchmark/lidar/ctpl/ctpl.h | \
    grep -v modules/planning/scenarios/stage_intersection_cruise_impl.cc | \
    grep -v modules/planning/scenarios/stop_sign/unprotected/stage_pre_stop.cc | \
    grep -v modules/planning/scenarios/stop_sign/unprotected/stage_stop.cc | \
    grep -v modules/planning/tasks/task_factory.cc | \
    grep -v modules/planning/traffic_rules/crosswalk.cc | \
    grep -v modules/planning/traffic_rules/stop_sign.cc | \
    grep -v modules/planning/traffic_rules/traffic_light.cc | \
    grep -v modules/prediction/container/obstacles/obstacle.cc | \
    grep -v modules/prediction/predictor/interaction/interaction_predictor.cc | \
    xargs -L 1 ./scripts/clang-format.sh

echo "clang-format: $(git status --short | wc -l)"
if [ ! -z "$(git diff)" ]; then
  git commit -a -m "Robot: Code clean with clang-format."
  CHANGED="yes"
fi

######################################################################### Commit
if [ "${CHANGED}" = "yes" ]; then
  git push origin +${BRANCH}
  /snap/bin/hub pull-request -m "Robot: Weekly code clean." -r kechxu,HongyiSun,Capri2014
fi
