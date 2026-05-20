#include <flutter/runtime_effect.glsl>

// ── Uniforms (set by _LiquidGlassPainter in index order) ─────────────────────
uniform float uTime;   // index 0  — seconds elapsed (from AnimationController)
uniform vec2  uSize;   // index 1,2 — logical-pixel canvas size

out vec4 fragColor;

// ── Value noise ───────────────────────────────────────────────────────────────
float hash(vec2 p) {
    p = fract(p * vec2(127.34, 311.72));
    p += dot(p, p + 17.23);
    return fract(p.x * p.y);
}

float snoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);  // smoothstep
    return mix(
        mix(hash(i),               hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    float t  = uTime * 0.28;

    // ── Refractive warp ───────────────────────────────────────────────────────
    // Two phase-offset noise samples drive the UV distortion — the slight
    // asymmetry (different speeds per axis) keeps the motion organic.
    float nx = snoise(uv * 3.2 + vec2(t * 0.55, t * 0.38));
    float ny = snoise(uv * 3.2 + vec2(t * 0.28, t * 0.62 + 1.73));
    vec2  wUv = uv + vec2(nx - 0.5, ny - 0.5) * 0.038;

    // ── Dark glass base ────────────────────────────────────────────────────────
    // Matches _kBg = 0xFF12131A  →  rgb(18,19,26) / 255 ≈ (0.071,0.075,0.102)
    vec3 col = vec3(0.071, 0.075, 0.102);

    // ── Animated blue-violet shimmer ──────────────────────────────────────────
    float s    = snoise(wUv * 4.8 + t * 0.40);
    vec3  shimA = vec3(0.00, 0.42, 0.62);   // teal-blue
    vec3  shimB = vec3(0.18, 0.04, 0.32);   // deep violet
    col += mix(shimA, shimB, s) * s * 0.065;

    // ── Primary specular highlight ────────────────────────────────────────────
    // Tight Gaussian blob — simulates a directional light glancing off curved glass.
    vec2  spec1  = vec2(0.62, 0.11);
    float dist1  = dot(uv - spec1, uv - spec1);
    col += exp(-dist1 * 40.0) * 0.24;

    // ── Secondary specular (dim counter-reflection) ───────────────────────────
    vec2  spec2  = vec2(0.80, 0.80);
    float dist2  = dot(uv - spec2, uv - spec2);
    col += exp(-dist2 * 55.0) * 0.08;

    // ── Luminous streak near top edge ─────────────────────────────────────────
    // Thin horizontal highlight — evokes the rim of a glass surface.
    float streak = exp(-pow((uv.y - 0.06) * 16.0, 2.0))
                 * smoothstep(0.05, 0.50, uv.x)
                 * smoothstep(0.95, 0.55, uv.x)
                 * 0.08;
    col += streak;

    // ── Iridescent edge fringe ────────────────────────────────────────────────
    // Slowly-cycling rainbow tint along all four edges.
    float edgeFactor = 1.0 - smoothstep(0.0, 0.09,
        min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    float hue  = uv.x + uv.y * 0.55 + t * 0.11;
    vec3  irid = vec3(
        0.5 + 0.5 * sin(hue * 6.2832 + 0.000),
        0.5 + 0.5 * sin(hue * 6.2832 + 2.094),
        0.5 + 0.5 * sin(hue * 6.2832 + 4.189)
    );
    col += edgeFactor * irid * 0.036;

    fragColor = vec4(col, 1.0);
}
