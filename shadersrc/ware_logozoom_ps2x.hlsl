// by pokemonPasta

#include "common.hlsl"

#define Time        Constants0.x
#define ZoomDepth   Constants0.y
#define ZoomFreq    Constants0.z
#define ZoomOffset  Constants0.w
#define XPos        Constants1.x
#define YPos        Constants1.y

float4 main( PS_INPUT i ) : COLOR
{
    float2 uv = i.baseTexCoord.xy;
    
    float zoom = ZoomDepth * sin(Time * ZoomFreq) + ZoomOffset;
    
    float2 logo = uv;
    
    logo.x -= (XPos - (TexBaseSize.x / (2.0*TexBaseSize.y)));
    logo.y += (YPos - (TexBaseSize.y / (2.0*TexBaseSize.y))); // slightly higher than centre
    logo *= zoom;
    logo.x *= 1.0 / (TexBaseSize.x / TexBaseSize.y);
    
    zoom /= 2.0;
    zoom -= 0.5;
    logo -= zoom;
    
    if(logo.x < 0.0 || logo.y < 0.0 || logo.x > 1.0 || logo.y > 1.0)
    {
        return tex2D(TexBase, uv);	
    }
    
    logo = clamp(logo, float2(0.0,0.0), float2(1.0,1.0));
    return tex2D(Tex1, logo);
    
}
