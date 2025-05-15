uniform float split : hint_range(0.0,1.0) = 0.5;
uniform bool  HALF_active  = true;

void Half(in vec2 uv, in sampler2D txt, in vec2 spriteSize, in vec2 pixelSize, inout vec4 finalColor){
    if (uv.x > split) discard;
    finalColor = texture(txt, uv);
}
