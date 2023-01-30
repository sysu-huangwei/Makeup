//
//  FilterFactory.cpp
//
//  Created by rayyy on 2021/9/23.
//

#include "FilterFactory.hpp"

#include "BaseLog.h"

#include "StickerFilter.hpp"

namespace effect {
    
std::shared_ptr<BaseFilter> FilterFactory::createFilter(const FilterDescription &filterDesc) {
    std::shared_ptr<BaseFilter> filter = nullptr;
    
    if (filterDesc.type == FilterType_Sticker) {
        filter = std::make_shared<StickerFilter>();
    } else {
        LOGE("Error: FilterFactory::createFilter: invalid filter type = %s", filterDesc.type.c_str());
        assert(false);
    }
    
    filter->setEnableRender(filterDesc.enable);
    filter->setOutputSize(filterDesc.outputWidth, filterDesc.outputHeight);
    filter->setParams(filterDesc.params);
    
    return filter;
}

}
