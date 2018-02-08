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

#include "modules/dreamview/backend/hmi/voice_detector.h"

#include <fstream>

#include "modules/common/log.h"
#include "modules/common/util/string_util.h"

namespace apollo {
namespace dreamview {

VoiceDetector::VoiceDetector(const VoiceCommand& config)
    : logger_(apollo::common::monitor::MonitorMessageItem::HMI) {
  std::string model_list;
  for (const auto &model : config.snowboy_models()) {
    if (model_list.empty()) {
      apollo::common::util::StrAppend(&model_list, model.path());
    } else {
      apollo::common::util::StrAppend(&model_list, ",", model.path());
    }

    for (const auto command : model.commands()) {
      voice_commands_.push_back(static_cast<VoiceCommand::Command>(command));
    }
  }

  snowboy_detector_.reset(
      new snowboy::SnowboyDetect(config.snowboy_resource(), model_list));
  snowboy_detector_->SetSensitivity(std::to_string(config.sensitivity()));
  CHECK_EQ(snowboy_detector_->NumHotwords(), voice_commands_.size())
      << "The models provide " << snowboy_detector_->NumHotwords()
      << " commands, while the config only lists " << voice_commands_.size();

  AINFO << "Running VoiceDetector with "
           "sensitivity=" << snowboy_detector_->GetSensitivity() << ", "
           "sample_rate=" << snowboy_detector_->SampleRate() << ", "
           "channels=" << snowboy_detector_->NumChannels() << ", "
           "bits_per_sample=" << snowboy_detector_->BitsPerSample();
}

void VoiceDetector::Detect(const std::string &wav) {
  const int hotword_index = snowboy_detector_->RunDetection(wav);

  // See definition of return values at
  // https://github.com/Kitt-AI/snowboy/blob/master/include/snowboy-detect.h#L58
  switch (hotword_index) {
    case -2:  // Silence.
      AINFO << "SnowboyDetect silence";
      return;
    case -1:  // Error.
      AERROR << "SnowboyDetect error.";
      return;
    case 0:  // No event.
      AINFO << "SnowboyDetect no event";
      return;
    default:  // voice_commands index.
      CHECK_LE(hotword_index, voice_commands_.size());
      Trigger(voice_commands_[hotword_index - 1]);
      return;
  }
}

void VoiceDetector::Trigger(const VoiceCommand::Command command) {
  // TODO(xiaoxq): Trigger real action.
  apollo::common::monitor::MonitorLogBuffer log_buffer(&logger_);
  log_buffer.INFO(
      "VoiceCommand triggered: " + VoiceCommand::Command_Name(command));
}

}  // namespace dreamview
}  // namespace apollo
