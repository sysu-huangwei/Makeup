//
//  StickerFilter.cpp
//
//  Created by rayyyhuang on 2022/11/2.
//

#include "StickerFilter.hpp"
#include "BaseGLUtils.hpp"

namespace effect {

void StickerFilter::init() {
    BaseFilter::initWithVertexStringAndFragmentString("simple", "sticker");
}

void StickerFilter::release() {
    BaseFilter::release();
    if (stickerTextureID > 0) {
        glDeleteTextures(1, &stickerTextureID);
        stickerTextureID = 0;
    }
}

void StickerFilter::renderToFrameBuffer(std::shared_ptr<FrameBuffer> outputFrameBuffer) {
    if (isNeedRender() && outputFrameBuffer) {
        outputFrameBuffer->activeFrameBuffer();
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glClearColor(0.0f,0.0f,0.0f,1.0f);
        
        program->use();
        
        program->setVertexAttribPointer("a_position", imageVertices);
        program->setVertexAttribPointer("a_texCoord", textureCoordinates);
        
        program->setTextureAtIndex("u_texture", inputFrameBuffers[0]->getTextureID(), 2 + inputFrameBufferIndices[0]);
        program->setTextureAtIndex("u_sticker", stickerTextureID, 3);
        program->setUniform1f("alpha", alpha);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glBindFramebuffer(GL_FRAMEBUFFER, GL_NONE);
    }
    
    unlockAndClearAllInputFrameBuffers();
}

void StickerFilter::setParams(const std::map<std::string, std::string> &param) {
    if (param.find(FilterParam_Sticker_Path) != param.end()) {
        setStickerImagePath(param.at(FilterParam_Sticker_Path));
    }
    if (param.find(FilterParam_Sticker_Alpha) != param.end()) {
        alpha = std::stof(param.at(FilterParam_Sticker_Alpha));
    }
}

void StickerFilter::setStickerImagePath(std::string path) {
    if (stickerTextureID > 0) {
        glDeleteTextures(1, &stickerTextureID);
        stickerTextureID = 0;
    }
    int width, height;
    this->stickerTextureID = BaseGLUtils::loadImageFileToTexture(path.c_str(), width, height);
}

}
