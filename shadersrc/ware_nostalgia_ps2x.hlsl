// by ficool2

#include "common.hlsl"

#define Time              Constants0.x
#define CurvatureStrength Constants0.y
#define ScanlineStrength  Constants0.z
#define NoiseStrength     Constants0.w
#define VignetteStrength  Constants1.x

float4 main( PS_INPUT i ) : COLOR
{
    float2 uv = i.baseTexCoord.xy * 2.0 - 1.0;

	// curvature
    float2 center = float2(0.0, 0.0);
    float dist = length(uv);
    uv += uv * dist * dist * CurvatureStrength;
    uv = (uv + 1.0) * 0.5;

	// tv mask
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
    {
        return float4(0.0, 0.0, 0.0, 1.0);
    }

    float4 color = tex2D(TexBase, uv);

    // scanlines
    float time = Constants0.x;
    float scanline = sin((i.baseTexCoord.y + Time * 0.07) * 300.0) * 0.5 + 0.5;
    color.rgb *= 1.0 - ScanlineStrength * (1.0 - scanline);

    // noise
    float noise = frac(sin(dot(i.baseTexCoord.xy + Time * 0.1, float2(12.9898, 78.233))) * 43758.5453);
    color.rgb += NoiseStrength * (noise - 0.5); 

    // desaturate
    float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    color.rgb = float3(luminance, luminance, luminance);

    // vignette
    float2 dist_sqr = (i.baseTexCoord.xy - 0.5) * (i.baseTexCoord.xy - 0.5);
    float vignette = 1.0 - (dist_sqr.x + dist_sqr.y) * 0.5;
    vignette = pow(vignette, VignetteStrength);
    color.rgb *= vignette;

    return color;
}
