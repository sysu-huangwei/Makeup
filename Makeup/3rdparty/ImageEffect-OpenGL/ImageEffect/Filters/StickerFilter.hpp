//
//  StickerFilter.hpp
//
//  Created by rayyyhuang on 2022/11/2.
//

#ifndef StickerFilter_hpp
#define StickerFilter_hpp

#include "BaseFilter.hpp"
#include "BaseDefine.h"

namespace effect {

/// 画贴纸的滤镜
class StickerFilter : public BaseFilter {
public:
    
    /// 滤镜的类型
    std::string filterType() override { return FilterType_Sticker; }
    
    /// 初始化，必须在GL线程，子类实现这个方法去做GL相关的初始化操作
    virtual void init() override;
    
    /// 释放资源，必须在GL线程，子类实现这个方法去做GL相关的释放操作
    virtual void release() override;
    
    /// 渲染，必须在GL线程
    /// @param outputFrameBuffer 目标FBO
    virtual void renderToFrameBuffer(std::shared_ptr<FrameBuffer> outputFrameBuffer) override;
    
    /// 设置参数
    /// @param param 参数
    virtual void setParams(const std::map<std::string, std::string> &param) override;
    
    /// 设置贴纸图路径，底层加载
    /// @param path 贴纸图的路径
    void setStickerImagePath(std::string path);
    
protected:
    unsigned stickerTextureID = 0;
    float alpha = 1.0f;
    
};

}


#endif /* StickerFilter_hpp */
