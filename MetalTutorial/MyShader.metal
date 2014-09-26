//
//  MyShader.metal
//  MetalTutorial
//
//  Created by Orlando Pereira on 20/08/14.
//  Copyright (c) 2014 RokkittGames. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float2 position;
} Triangle;

typedef struct {
    float4 position [[position]];
} TriangleOutput;

vertex TriangleOutput VertexColor(const device Triangle *Vertices [[buffer(0)]], const uint index [[vertex_id]])
{
    TriangleOutput out;
    out.position = float4(Vertices[index].position, 0.0, 1.0);
    return out;
}

fragment half4 FragmentColor(void)
{
    return half4(1.0, 0.0, 0.0, 1.0);
}