#include "Functions.glsl"
uniform vec2 canvasRes;
uniform float uPixelRatio;
uniform float uTime;
uniform float uDeltaTime;
varying vec2 vUv;


void main() {
    // Use pixel coordinates with fixed reference scale for resolution independence
    // Divide by pixelRatio to normalize device pixels to CSS pixels,
    // then scale: x by 1/1080 and y by 2/1080 to match original proportions
    vec2 uv = gl_FragCoord.xy / (uPixelRatio * 1080.0) * vec2(1.0, 2.0);




    // Generate animated simplex noise that varies over space and time
    // Higher multiplier (2.0) creates more detailed noise pattern
    float n = snoise(uv * 0.5 + uTime/5.0);

    // Create a repeating grid of 70 cells, warped by noise
    float gridSize = 300.0;
    // Each cell's UV goes from -0.5 to 0.5, centered at origin
    // Grid dynamically distorts based on noise (n*4.0)
    vec2 cellUv = mod(uv * (gridSize + n*4.0), 1.0) - 0.5;

    // Compute distance from center of each cell
    float dist = distance(cellUv, vec2(0.0));

    // Define circle radius and create smooth anti-aliased edges
    float radius = 0.1;
    // smoothstep creates gradient from 1.0 (at center) to 0.0 (at radius edge)
    float intensity = smoothstep(radius, radius - radius/1.0, dist);

    // Blend between dark gray (0.05) and light gray (0.7) based on circle intensity
    vec4 color = vec4(mix(vec3(0.05),vec3(0.7),intensity), 1.0);

    // Output final color to screen
    gl_FragColor = color;
}
