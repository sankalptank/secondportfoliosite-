// Functions.glsl
// Common utility functions for Anisotropic Kuwahara

const float PI = 3.14159265358979323846;

float gaussian(float sigma, float pos) {
    return (1.0 / sqrt(2.0 * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0 * sigma * sigma));
}

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Smooth interpolation
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Blend four corners
    return mix(
        mix(rand(i + vec2(0.0, 0.0)), rand(i + vec2(1.0, 0.0)), u.x),
        mix(rand(i + vec2(0.0, 1.0)), rand(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x * 34.0) + 1.0) * x);
}

vec2 fade(vec2 t) {
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187,  // (3.0 - sqrt(3.0)) / 6.0
                      0.366025403784439,  // 0.5 * (sqrt(3.0) - 1.0)
                      -0.577350269189626, // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0

  vec2 i = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);

  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

  vec2 x1 = x0.xy - i1 + C.xx;
  vec2 x2 = x0.xy - 1.0 + 2.0 * C.xx;

  i = mod289(i);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
                 + i.x + vec3(0.0, i1.x, 1.0));

  vec3 x = fract(p * C.w) * 2.0 - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  vec2 g0 = vec2(a0.x, h.x);
  vec2 g1 = vec2(a0.y, h.y);
  vec2 g2 = vec2(a0.z, h.z);

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  m = m * m;
  m = m * m;

  vec3 g;
  g.x = dot(g0, x0);
  g.y = dot(g1, x1);
  g.z = dot(g2, x2);

  return 130.0 * dot(m, g);
}

float fbm(vec2 p, int octaves, float lacunarity, float gain) {
    float amplitude = 1.0;
    float frequency = 1.0;
    float sum = 0.0;
    for (int i = 0; i < 20; ++i) { // loop unroll safe-guard; only use up to octaves
        if (i >= octaves) break;
        sum += amplitude * snoise(p * frequency);
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return sum;
}
