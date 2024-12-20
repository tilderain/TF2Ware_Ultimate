// by pokemonPasta
// adapted from https://inspirnathan.com/posts/55-shadertoy-tutorial-part-9#tiltingrotating-the-camera

#include "common.hlsl"

float2x2 rotateZ(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return float2x2(
        float2(c, -s),
        float2(s,  c)
    );
}

float4 main( PS_INPUT i ) : COLOR
{
    float2 uv = i.baseTexCoord;
    
    // shift and scale to normal cartesian plane
    uv -= 0.5;
   uv *= 2.0;
    
    // multiply by rotation matrix
    uv = mul(uv, rotateZ(radians(45.0)));
    
    // shift and scale back
    uv /= (22.0/9.0); // NOTE: this is for fov 110, change this to be 2 * (ratio between your fov and 90) (this needs a high fov no matter what or the corners stretch)
    uv += 0.5;
    
	return tex2D(TexBase, uv);
}
