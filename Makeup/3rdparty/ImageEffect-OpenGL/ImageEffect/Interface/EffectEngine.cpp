//
//  EffectEngine.cpp
//
//  Created by rayyy on 2021/11/9.
//

#include "EffectEngine.hpp"
#include "BaseGLUtils.hpp"
#include "EffectConfigParser.hpp"
#include "BaseDefine.h"
#include "StickerFilter.hpp"

namespace effect {

EffectEngine::EffectEngine(std::string configFilePath) {
    unsigned long dataSise;
    char *json = BaseGLUtils::loadFileToMemory(configFilePath.c_str(), dataSise);
    nodeDescriptions = EffectConfigParser::parseJsonToDescription(std::string(json));
    SAFE_DELETE_ARRAY(json);
};


void EffectEngine::setSticker(std::string path) {
    for (int i = 0; i < allNodes.size(); i++) {
        std::shared_ptr<StickerFilter> stickerFilter = std::dynamic_pointer_cast<StickerFilter>(allNodes[i]->filter);
        if (stickerFilter) {
            stickerFilter->setStickerImagePath(path);
        }
    }
}

}
