#include <metal_stdlib>
using namespace metal;


vertex float4 vertex_main(const device float4 *vertices [[buffer(0)]], constant float4x4 &transformation [[buffer(1)]], uint vid [[vertex_id]])
{
    return vertices[vid];
}

fragment float4 fragment_main(float4 inVertex [[stage_in]]) {
    return float4(1, 1, 1, 1);
}
