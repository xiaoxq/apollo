/******************************************************************************
 * Copyright 2018 The Apollo Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************/

#ifndef MODULES_DREAMVIEW_BACKEND_HMI_VOICE_DETECTOR_H_
#define MODULES_DREAMVIEW_BACKEND_HMI_VOICE_DETECTOR_H_

#include <string>

#include "snowboy-detect.h"

#include "modules/common/monitor_log/monitor_log_buffer.h"
#include "modules/dreamview/proto/hmi_config.pb.h"

/**
 * @namespace apollo::dreamview
 * @brief apollo::dreamview
 */
namespace apollo {
namespace dreamview {

class VoiceDetector {
 public:
  explicit VoiceDetector(const VoiceCommand& config);

  // Detect audio piece in webm format.
  void Detect(const std::string &wav);
  void Trigger(const VoiceCommand::Command command);

 private:
  std::unique_ptr<snowboy::SnowboyDetect> snowboy_detector_;
  std::vector<VoiceCommand::Command> voice_commands_;

  apollo::common::monitor::MonitorLogger logger_;
};

}  // namespace dreamview
}  // namespace apollo

#endif  // MODULES_DREAMVIEW_BACKEND_HMI_VOICE_DETECTOR_H_
