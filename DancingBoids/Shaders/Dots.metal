#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Transformation {
    float4x4 rotation;
    float4x4 translation;
};

struct Uniforms {
    float4x4 projectionMatrix;
};

vertex Vertex vertex_main(const device Vertex *vertices [[buffer(0)]],
                          const device Transformation *transformations [[buffer(1)]],
                          constant Uniforms &uniforms [[buffer(2)]],
                          uint vid [[vertex_id]])
{
    Vertex vertexOut;
    float4x4 transformation =  transformations[vid].rotation * transformations[vid].translation * uniforms.projectionMatrix;
    vertexOut.position =  vertices[vid].position * transformation;
    vertexOut.color = vertices[vid].color;
    return vertexOut;
}

fragment float4 fragment_main(Vertex inVertex [[stage_in]]) {
    if (inVertex.position.y > 200) {
        return float4(1, 1, 1, 1);
    }
    return inVertex.color;
}
