#ifndef _MKL_VIEW_H_
#define _MKL_VIEW_H_

#include <stdint.h>

#include "../MKLWindow.h"
#include "../Core/MKLCore.h"
#include "Objects/MKLEntity.h"

#include "MKLColors.h"
#include "MKLTypes.h"

#ifdef __OBJC__
#import <MetalKit/MetalKit.h>

@interface MTKView (TrackingArea)

- (void)addCustomTrackingArea;

@end

@interface MklBufferPool : NSObject

@property (nonatomic, readonly) id<MTLDevice> device;
@property (nonatomic, readonly) NSMutableArray<id<MTLBuffer>> *buffers;

- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device;
- (id<MTLBuffer>)getBufferWithBytes:(const void *)bytes length:(NSUInteger)length;

- (void)releaseBuffers;
@end
#endif

typedef struct MKLRenderer
{
    MKLWindow *window;
    MKLUniforms uniforms;
    MKLCamera camera;
#ifdef __OBJC__
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    MTKView *_view;
    CAMetalLayer *_metalLayer;
    MTLClearColor _clearColor;
    MklBufferPool *_bufferPool;
    MTKMeshBufferAllocator *_bufferAllocator;
    // library variables
    id<MTLLibrary> _library;
    MTLRenderPassDescriptor *_renderPassDescriptor;
    MTLVertexDescriptor *_vertexDescriptor;
    MDLVertexDescriptor *_mdlVertexDescriptor;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLDepthStencilState> _depthStencilState;
    // drawing variables
    NSAutoreleasePool *_pool;
    id<CAMetalDrawable> _drawable;
    id<MTLCommandBuffer> _commandBuffer;
    id<MTLRenderCommandEncoder> _renderEncoder;
#endif
} MKLRenderer;

MKLAPI MKLRenderer *MKLCreateRenderer(MKLWindow *window);

MKLAPI void MKLClearRenderer(MKLRenderer *renderer, MKLColor color);

MKLAPI void MKLBeginDrawing(MKLRenderer *renderer);

MKLAPI void MKLEndDrawing(MKLRenderer *renderer);

MKLAPI void MKLDestroyRenderer(MKLRenderer *renderer);

#endif // _MKL_VIEW_H_