const std = @import("std");

pub fn Vector(comptime Len: comptime_int, comptime T: type) type {
    return struct {
        pub const Type = @Vector(Len, T);
        pub const len = Len;
        pub const ChildType = T;

        pub usingnamespace switch (Len) {
            inline 2, 3, 4 => struct {
                const VectorInitStruct: type = blk: {
                    var fields: []const std.builtin.Type.StructField = &[0]std.builtin.Type.StructField{};
                    const component_names = std.meta.fieldNames(VectorComponents);
                    for (0..Len) |c| {
                        fields = fields ++ [_]std.builtin.Type.StructField{.{
                            .name = component_names[c] ++ [1:0]u8{0},
                            .type = ChildType,
                            .default_value = null,
                            .is_comptime = false,
                            .alignment = @alignOf(@TypeOf(ChildType)),
                        }};
                    }

                    break :blk @Type(.{ .Struct = .{
                        .layout = .Auto,
                        .is_tuple = false,
                        .fields = fields,
                        .decls = &[_]std.builtin.Type.Declaration{},
                    } });
                };

                pub fn init(v: VectorInitStruct) Type {
                    var array: [Len]ChildType = undefined;
                    const fields = std.meta.fields(VectorInitStruct);
                    inline for (fields, 0..) |f, i| {
                        array[i] = @field(v, f.name);
                    }
                    return array;
                }
            },
            else => struct {
                pub fn init(v: [Len]ChildType) Type {
                    return v;
                }
            },
        };

        pub fn splat(scalar: T) Type {
            return @splat(scalar);
        }

        pub const VectorComponents = enum(usize) { x, y, z, w };
        // Runtime swizzle, supports vec2, vec3 and vec4
        pub inline fn swizzle(v: Type, components: [Len]VectorComponents) Type {
            var array: [Len]ChildType = undefined;
            inline for (&components, 0..) |elem, index| {
                array[index] = v[@intFromEnum(elem)];
            }
            return array;
        }

        // Uses @shuffle to apply the swizzle, you can generate @Vector of any size using this function (the mask must be known at comptime).
        pub inline fn swizzleComptime(v: Type, comptime mask: []const i32) @Vector(mask.len, ChildType) {
            return @shuffle(ChildType, v, undefined, mask);
        }

        pub inline fn lengthSq(v: Type) ChildType {
            var sum: ChildType = 0.0;
            inline for (0..Len) |i| {
                sum += v[i] * v[i];
            }
            return sum;
        }

        pub inline fn length(v: Type) ChildType {
            return std.math.sqrt(lengthSq(v));
        }

        pub inline fn normalize(v: Type) Type {
            return v / splat(length(v));
        }

        pub inline fn distanceSq(v1: Type, v2: Type) ChildType {
            return lengthSq(v2 - v1);
        }

        pub inline fn distance(v1: Type, v2: Type) ChildType {
            return length(v2 - v1);
        }

        pub inline fn direction(v1: Type, v2: Type) Type {
            return normalize(v2 - v1);
        }

        pub inline fn lerp(v1: Type, v2: Type, amount: ChildType) Type {
            return v1 * splat(1 - amount) + v2 * splat(amount);
        }

        pub inline fn dot(v1: Type, v2: Type) ChildType {
            return @reduce(.Add, v1 * v2);
        }

        pub inline fn max(v1: Type, v2: Type) Type {
            var m: [Len]ChildType = undefined;
            inline for (0..Len) |i| {
                m[i] = @max(v1[i], v2[i]);
            }
            return m;
        }

        pub inline fn min(v1: Type, v2: Type) Type {
            var m: [Len]ChildType = undefined;
            inline for (0..Len) |i| {
                m[i] = @min(v1[i], v2[i]);
            }
            return m;
        }

        pub inline fn inverse(v1: Type) Type {
            return splat(1) / v1;
        }

        pub inline fn negate(v1: Type) Type {
            return splat(-1) * v1;
        }

        pub inline fn equalApprox(v1: Type, v2: Type, tolerance: ChildType) bool {
            inline for (0..Len) |i| {
                if (!std.math.approxEqAbs(ChildType, v1[i], v2[i], tolerance)) return false;
            }
            return true;
        }

        pub inline fn equal(v1: Type, v2: Type) bool {
            return equalApprox(v1, v2, std.math.floatEps(ChildType));
        }

        pub usingnamespace if (Len == 3) struct {
            pub fn cross(v1: Type, v2: Type) Type {
                return .{
                    v1[1] * v2[2] - v1[2] * v2[1],
                    v1[2] * v2[0] - v1[0] * v2[2],
                    v1[0] * v2[1] - v1[1] * v2[0],
                };
            }
        } else struct {};
    };
}
