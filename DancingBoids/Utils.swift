import simd
import MetalKit
import GLKit
import Flockingbird

func translationMatrix(dx: Float, dy: Float) -> matrix_float4x4 {
    .init(.init(1, 0, 0, dx),
          .init(0, 1, 0, dy),
          .init(0, 0, 1, 0),
          .init(0, 0, 0, 1))
}

func  rotationMatrix(theta: Float) -> simd_float4x4
{
    return  .init(.init(cos(theta), -sin(theta), 0, 0),
                  .init(sin(theta), cos(theta), 0, 0),
                  .init(0, 0, 1, 0),
                  .init(0, 0, 0, 1))
}

extension simd_float4x4 {
    init(matrix m: GLKMatrix4) {
        self.init(columns: (
            simd_float4(x: m.m00, y: m.m01, z: m.m02, w: m.m03),
            simd_float4(x: m.m10, y: m.m11, z: m.m12, w: m.m13),
            simd_float4(x: m.m20, y: m.m21, z: m.m22, w: m.m23),
            simd_float4(x: m.m30, y: m.m31, z: m.m32, w: m.m33)))
    }
}


func normaliseCoord(frame: CGRect, boid: Boid) -> (x: Float, y: Float)  {
    // TODO: make the library capable of dealing with -1, 1 coordinate space
    let aspect = Float(frame.width / frame.height)
    let x = 2 * (boid.position.x / Float(frame.width)) - 1
    let y = (2 * (boid.position.y / Float(frame.height)) - 1) / aspect
    return (x: x, y: y)
}

func buildProjectionMatrix(width: Float, height: Float) -> simd_float4x4 {
    let aspect = width / height
    let projectionMatrix = GLKMatrix4MakeOrtho(-aspect, aspect,
                                                -1, 1,
                                                -1, 1)
    var modelViewMatrix = GLKMatrix4Identity
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, aspect, -aspect, 1.0)
    let out = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
    return simd_float4x4(matrix: out)
}
