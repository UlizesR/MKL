#import "MKLObjects.h"
#import "../MKLTypes.h"
#import "../../Math/MKLMath.h"

#import <simd/matrix.h>

#import <Metal/Metal.h>

void MKLDrawAxis(MKLRenderer* renderer, float length)
{
    if (renderer == nil)
    {
        NSLog(@"MKLDrawAxis: renderer is nil");
        return;
    }

    vector_float4 x_axis = simd_make_float4(length, 0.0f, 0.0f, 1.0f);
    vector_float4 y_axis = simd_make_float4(0.0f, length, 0.0f, 1.0f);
    vector_float4 z_axis = simd_make_float4(0.0f, 0.0f, length, 1.0f);

    matrix_float4x4 axisModelMatrix = {
        .columns[0] = x_axis,
        .columns[1] = y_axis,
        .columns[2] = z_axis,
        .columns[3] = WORLD_ORIGIN
    };

    vector_float4 colors[3] = {MKL_COLOR_RED, MKL_COLOR_GREEN, MKL_COLOR_BLUE};

    MKLVertex lineVertices[6] = {
        {.position = WORLD_ORIGIN},
        {.position = x_axis},
        {.position = WORLD_ORIGIN},
        {.position = y_axis},
        {.position = WORLD_ORIGIN},
        {.position = z_axis}
    };

    [renderer->_renderEncoder setVertexBytes:&axisModelMatrix length:sizeof(matrix_float4x4) atIndex:3];

    id<MTLBuffer> vertexBuffer = [renderer->_bufferPool getBufferWithBytes:lineVertices
                                                                     length:sizeof(lineVertices)];

    if (vertexBuffer == nil) 
    {
        NSLog(@"MKLDrawAxisHelper: Failed to create vertex buffer");
        return;
    }

    [renderer->_renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];

    for (int i = 0; i < 3; i++)
    {
        [renderer->_renderEncoder setVertexBytes:&colors[i] length:sizeof(vector_float4) atIndex:2];
        [renderer->_renderEncoder drawPrimitives:MTLPrimitiveTypeLine vertexStart:i*2 vertexCount:2];
    }
}