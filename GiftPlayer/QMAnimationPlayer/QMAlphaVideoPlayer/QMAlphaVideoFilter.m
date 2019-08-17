//
//  QMAlphaVideoFilter.m
//  StarMaker
//
//  Created by 江林 on 2019/7/19.
//  Copyright © 2019 uShow. All rights reserved.
//

#import "QMAlphaVideoFilter.h"

NSString *const kGPUImageCombineVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate.xy+vec2(0.5,0);
//     textureCoordinate2 = vec2(inputTextureCoordinate.x + 0.5, inputTextureCoordinate.y);
     
 }
);

NSString *const kGPUImageCombineFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform highp float alpha;
 
 void main()
 {
     gl_FragColor = vec4(texture2D(inputImageTexture, textureCoordinate2).rgb, texture2D(inputImageTexture, textureCoordinate).r);
 }
);

@implementation QMAlphaVideoFilter
- (id)init {
    if (!(self = [super initWithVertexShaderFromString:kGPUImageCombineVertexShaderString
                              fragmentShaderFromString:kGPUImageCombineFragmentShaderString])) {
        return nil;
    }
    return self;
}


#pragma mark -
#pragma mark Accessors

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    if (self.preventRendering) {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture) {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    static const GLfloat textureCoordinates1[] = {
        0.0f, 0.0f,
        0.5f, 0.0f,
        0.0f, 1.0f,
        0.5f, 1.0f,
    };
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates1);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex; {
    if (self.preventRendering) {
        return;
    }
    inputTextureSize = CGSizeMake(newSize.width/2.0f, newSize.height);
}

@end
