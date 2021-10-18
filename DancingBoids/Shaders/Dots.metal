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

vertex Vertex vertex_main(const device Vertex *vertices [[buffer(0)]], constant Transformation *transformations [[buffer(1)]], uint vid [[vertex_id]])
{
    Vertex vertexOut;
    vertexOut.position = vertices[vid].position;
    vertexOut.position = transformations[vid].rotation * vertexOut.position;
    vertexOut.position = transformations[vid].translation * vertexOut.position;
    vertexOut.color = vertices[vid].color;
    return vertexOut;
}

fragment float4 fragment_main(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}
