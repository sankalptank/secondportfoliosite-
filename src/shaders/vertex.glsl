varying vec3 v_Normal;
varying vec3 pos;
varying vec2 vUv;

void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    v_Normal = normal;
    pos = (modelMatrix * vec4(position, 1.0)).xyz;
    vUv = pos.xy;
}
