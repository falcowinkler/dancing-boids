#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
    float pointsize[[point_size]];
};

vertex Vertex vertex_main(const device Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]])
{
    return vertices[vid];
}

fragment float4 fragment_main(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}

fragment half4 basic_fragment() {
    return half4(1.0);
}

vertex float4 basic_vertex(
                           const device packed_float3* vertex_array [[ buffer(0) ]],
                           unsigned int vid [[ vertex_id ]]) {
                               return float4(vertex_array[vid], 1.0);
                           }
