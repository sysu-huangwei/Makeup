//
//  GLView.m
//  PhotoRetoucher
//
//  Created by rayyyhuang on 2022/11/14.
//

#import "GLView.h"
#import <OpenGLES/ES3/gl.h>
#include "EffectEngine.hpp"
#import "UIImage+TransferImageData.h"
#include "InputImageFrameBuffer.hpp"
#include "OutputFrameBuffer.hpp"

@interface GLView()
{
    CAEAGLLayer *_eaglLayer;  //OpenGL内容只会在此类layer上描绘
    EAGLContext *_context;    //OpenGL渲染上下文
    GLuint _renderBuffer;     //
    GLuint _frameBuffer;      //
    effect::EffectEngine *effectEngine;
    
    std::shared_ptr<effect::InputImageFrameBuffer> inputFrameBuffer;
    std::shared_ptr<effect::OutputFrameBuffer> outputFrameBuffer;
    
    std::string stickerPath;
}
@end

@implementation GLView

+ (Class)layerClass{
    //OpenGL内容只会在此类layer上描绘
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupSticker];
    }
    
    return self;
}

- (instancetype)init {
    if (self == [super init]) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupSticker];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self == [super initWithCoder:coder]) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupSticker];
    }
    
    return self;
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见,性能最好
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    // 指定 OpenGLES 渲染API的版本，在这里我们使用OpenGLES 3.0，由于3.0兼容2.0并且功能更强，为何不用更好的呢
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
    }
    
    // 设置为当前上下文
    [EAGLContext setCurrentContext:_context];
}

- (void)setupRenderBuffer {
//    [EAGLContext setCurrentContext:_context];
    glGenRenderbuffers(1, &_renderBuffer); //生成和绑定render buffer的API函数
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    //为其分配空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
//    [EAGLContext setCurrentContext:_context];
    glGenFramebuffers(1, &_frameBuffer);   //生成和绑定frame buffer的API函数
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //将renderbuffer跟framebuffer进行绑定
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    GLint backingWidth, backingHeight;

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    outputFrameBuffer = std::make_shared<effect::OutputFrameBuffer>();
    outputFrameBuffer->initWithFrameBufferID(_frameBuffer, self.frame.size.width, self.frame.size.height);
}

- (void)setupEngine {
    [EAGLContext setCurrentContext:_context];
    NSString *configFilePath = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"ImageEffect.bundle/descriptions/PhotoRetoucher.json"];
    self->effectEngine = new effect::EffectEngine(configFilePath.UTF8String);
    self->effectEngine->init();
    self->effectEngine->setOutputSize(self.frame.size.width, self.frame.size.height);
    
}

- (void)setupSticker {
    stickerPath = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"makeup/makeup.png"].UTF8String;
}


- (void)setInputImage:(UIImage *)image {
    if (!inputFrameBuffer) {
        [EAGLContext setCurrentContext:_context];
        inputFrameBuffer = std::make_shared<effect::InputImageFrameBuffer>();
        unsigned char *rgbaData = [image transferToRGBAData];
        inputFrameBuffer->initWithRGBAImageData(rgbaData, (int)image.size.width, (int)image.size.height);
        SAFE_DELETE_ARRAY(rgbaData);
        [self setupEngine];
    } else {

    }
}

- (void)render {
    [EAGLContext setCurrentContext:_context];
    
    self->effectEngine->setSticker(stickerPath);
    
    self->effectEngine->setInputFrameBufferAtIndex(inputFrameBuffer);
    self->effectEngine->renderToFrameBuffer(outputFrameBuffer);
    [_context presentRenderbuffer:_renderBuffer];
}


- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha {
    std::map<std::string, std::string> params;
    switch (type) {
        case EffectType_Sticker:
            params = {
                { FilterParam_Sticker_Alpha, std::to_string(alpha) }
            };
            break;
        default:
            break;
    }
    effectEngine->setParams(params);
}

@end
