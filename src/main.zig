const std = @import("std");

pub const VectorGenerator = @import("Vector.zig").Vector;
pub const MatrixGenerator = @import("Mat.zig").MatrixGenerator;

// Tried to retain most of the arithmetic operation with @Vector() operator for ease of use
// I feel like vec1 * vec2 is nicer than vec1.mul(vec2), but it makes vector type definition awkward.
//
// For example:
// pub fn doSomethingWithVector(v1: @Vector(3, f32)) @Vector(3, f32) {}
// Typing @Vector(3, f32) eveytime is heavy
// But since Vec3 is taken for functions definition, we have to replace it with vec3 like for matrices. I feel like this make it hard to tell which is a type and which is the "namespace"
// An other solution could be Vec3.Type, I don't know how I feel about this one yet.
pub const Vec2 = VectorGenerator(2, f32);
pub const Vec3 = VectorGenerator(3, f32);
pub const Vec4 = VectorGenerator(4, f32);

// Same things with Vectors but here since the type is [C]@Vector(R, Type), I provide the type has matCxR for simplicity, but I don't like it :')
pub const Mat2x2 = MatrixGenerator(2, 2, f32);
pub const mat2x2 = Mat2x2.MatrixType;
pub const Mat3x3 = MatrixGenerator(3, 3, f32);
pub const mat3x3 = Mat3x3.MatrixType;
pub const Mat4x4 = MatrixGenerator(4, 4, f32);
pub const mat4x4 = Mat4x4.MatrixType;

pub const Vec2h = VectorGenerator(2, f16);
pub const Vec3h = VectorGenerator(3, f16);
pub const Vec4h = VectorGenerator(4, f16);
pub const Mat2x2h = MatrixGenerator(2, 2, f16);
pub const Mat3x3h = MatrixGenerator(3, 3, f16);
pub const Mat4x4h = MatrixGenerator(4, 4, f16);

pub const Vec2d = VectorGenerator(2, f64);
pub const Vec3d = VectorGenerator(3, f64);
pub const Vec4d = VectorGenerator(4, f64);
pub const Mat2x2d = MatrixGenerator(2, 2, f64);
pub const Mat3x3d = MatrixGenerator(3, 3, f64);
pub const Mat4x4d = MatrixGenerator(4, 4, f64);

// Experimental: Test and verify usage
pub const Rotor = @import("Rotor.zig").Rotor;

// Constants
pub const pi = std.math.pi;
pub const two_sqrtpi = std.math.two_sqrtpi;
pub const sqrt2 = std.math.sqrt2;
pub const sqrt1_2 = std.math.sqrt1_2;

pub const eql = std.math.approxEqAbs;
pub const eps = std.math.floatEps;
pub const eps_f16 = std.math.floatEps(f16);
pub const eps_f32 = std.math.floatEps(f32);
pub const eps_f64 = std.math.floatEps(f64);
pub const nan_f16 = std.math.nan(f16);
pub const nan_f32 = std.math.nan(f32);
pub const nan_f64 = std.math.nan(f64);

pub const inf = std.math.inf;
pub const sqrt = std.math.sqrt;
pub const sin = std.math.sin;
pub const cos = std.math.cos;
pub const tan = std.math.tan;
pub const isNan = std.math.isNan;
pub const isInf = std.math.isInf;
pub const clamp = std.math.clamp;
pub const log10 = std.math.log10;
pub const degreesToRadians = std.math.degreesToRadians;
pub const radiansToDegrees = std.math.radiansToDegrees;

pub fn convertMat4x4ToMat3x3(m: mat4x4) mat3x3 {
    const c0 = Mat4x4.column(m, 0);
    const c1 = Mat4x4.column(m, 1);
    const c2 = Mat4x4.column(m, 2);
    return .{
        .{ c0[0], c0[1], c0[2] },
        .{ c1[0], c1[1], c1[2] },
        .{ c2[0], c2[1], c2[2] },
    };
}

pub fn perspective(fovy: f32, aspect_ratio: f32, near: f32, far: f32) mat4x4 {
    const c = cos(fovy * 0.5);
    const s = sin(fovy * 0.5);
    const h = c / s;
    const w = h / aspect_ratio;
    const r = near - far;
    return Mat4x4.init(.{
        .{ w, 0, 0, 0 },
        .{ 0, h, 0, 0 },
        .{ 0, 0, (near + far) / r, 2.0 * near * far / r },
        .{ 0, 0, -1, 0 },
    });
}

pub fn lookAt(eye: @Vector(3, f32), target: @Vector(3, f32), worldUp: @Vector(3, f32)) mat4x4 {
    const direction = target - eye;
    const forward = Vec3.normalize(direction);
    const right = Vec3.normalize(Vec3.cross(forward, worldUp));
    const up = Vec3.normalize(Vec3.cross(right, forward));
    var mat = Mat4x4.identity();
    mat[0][0] = right[0];
    mat[1][0] = right[1];
    mat[2][0] = right[2];

    mat[0][1] = up[0];
    mat[1][1] = up[1];
    mat[2][1] = up[2];

    mat[0][2] = -forward[0];
    mat[1][2] = -forward[1];
    mat[2][2] = -forward[2];

    mat[3][0] = -Vec3.dot(right, eye);
    mat[3][1] = -Vec3.dot(up, eye);
    mat[3][2] = Vec3.dot(forward, eye);
    return mat;
}
