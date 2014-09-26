//
//  ViewController.m
//  MetalTutorial
//
//  Created by Orlando Pereira on 18/08/14.
//  Copyright (c) 2014 RokkittGames. All rights reserved.
//

#import "ViewController.h"

#import <Metal/Metal.h>
#import <GLKit/GLKMath.h>
#import <QuartzCore/CAMetalLayer.h>

typedef struct {
    GLKVector2 position;
}Triangle;

@interface ViewController ()

@end

@implementation ViewController
{
    id <MTLDevice> mtlDevice;
    id <MTLCommandQueue> mtlCommandQueue;
    
    MTLRenderPassDescriptor *mtlRenderPassDescriptor;
    CAMetalLayer *metalLayer;
    id <CAMetalDrawable> frameDrawable;
    
    CADisplayLink *displayLink;
    
    MTLRenderPipelineDescriptor *renderPipelineDescriptor;
    id <MTLRenderPipelineState> renderPipelineState;
    
    id <MTLBuffer> object;
}
            
- (void)viewDidLoad {
    [super viewDidLoad];

    mtlDevice = MTLCreateSystemDefaultDevice();
    mtlCommandQueue = [mtlDevice newCommandQueue];

    metalLayer = [CAMetalLayer layer];
    [metalLayer setDevice:mtlDevice];
    [metalLayer setPixelFormat:MTLPixelFormatBGRA8Unorm];
    
    metalLayer.framebufferOnly = YES;
    [metalLayer setFrame:self.view.layer.frame];
    [self.view.layer addSublayer:metalLayer];

    [self.view setOpaque:YES];
    [self.view setBackgroundColor:nil];
    [self.view setContentScaleFactor:[UIScreen mainScreen].scale];
    
    // Create a reusable pipeline state
    renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    // shaders
    id <MTLLibrary> lib = [mtlDevice newDefaultLibrary];
    renderPipelineDescriptor.vertexFunction = [lib newFunctionWithName:@"VertexColor"];
    renderPipelineDescriptor.fragmentFunction = [lib newFunctionWithName:@"FragmentColor"];
    
    renderPipelineState = [mtlDevice newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error: nil];
    
    Triangle triangle[3] = {
        { -.5f, 0.0f },
        { 0.5f, 0.0f },
        { 0.0f, 0.5f }
    };
    
    object = [mtlDevice newBufferWithBytes:&triangle length:sizeof(Triangle[3]) options:MTLResourceOptionCPUCacheModeDefault];
    [object setLabel:@"MyTriangle"];
    
    displayLink = [CADisplayLink displayLinkWithTarget: self selector: @selector(renderScene)];
    [displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
}

-(void)renderScene
{
    id <MTLCommandBuffer>mtlCommandBuffer = [mtlCommandQueue commandBuffer];
    
    while (!frameDrawable){
        frameDrawable = [metalLayer nextDrawable];
    }
    if (!mtlRenderPassDescriptor)
        mtlRenderPassDescriptor = [MTLRenderPassDescriptor new];
    
    mtlRenderPassDescriptor.colorAttachments[0].texture = frameDrawable.texture;
    mtlRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    mtlRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.75, 0.25, 1.0, 1.0);
    mtlRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    id <MTLRenderCommandEncoder> renderCommand = [mtlCommandBuffer renderCommandEncoderWithDescriptor: mtlRenderPassDescriptor];
    // Draw objects here
    [renderCommand pushDebugGroup:@"DebugTriangle"];
    
    [renderCommand setViewport: (MTLViewport){ 0.0, 0.0, metalLayer.drawableSize.width, metalLayer.drawableSize.height, 0.0, 1.0 }];
    
    [renderCommand setRenderPipelineState:renderPipelineState]; // Order is important!!
    [renderCommand setVertexBuffer:object offset:0 atIndex:0];
    [renderCommand drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:3];
    
    [renderCommand popDebugGroup];
    
    [renderCommand endEncoding];
    
    [mtlCommandBuffer presentDrawable: frameDrawable];
    [mtlCommandBuffer commit];
    
    mtlRenderPassDescriptor = nil;
    frameDrawable = nil;
}

-(void) dealloc
{
    [displayLink invalidate];
    mtlDevice = nil;
    mtlCommandQueue = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
