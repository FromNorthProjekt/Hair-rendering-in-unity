// LitRW_ShadowCasterPass.hlsl
#ifndef LIT_RW_SHADOWCASTER_PASS_INCLUDED
#define LIT_RW_SHADOWCASTER_PASS_INCLUDED

#pragma target 2.0
#pragma vertex ShadowPassVertex
#pragma fragment LitRW_ShadowFragment // Use a custom fragment function

// --- Keywords ---
#pragma shader_feature_local _ALPHATEST_ON
#pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT // We need this to know when to dither
#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
#pragma multi_compile _ LOD_FADE_CROSSFADE
#pragma multi_compile_instancing
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

// --- Includes ---
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
// Corrected include path for LOD Fade
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

// --- Blue Noise Dithering ---
// URP doesn't expose the blue noise texture by default, so we declare it ourselves.
// The renderer will bind it if it's available.
TEXTURE2D(_BlueNoiseTexture);
SAMPLER(sampler_BlueNoiseTexture);
float4 _BlueNoiseTexture_TexelSize; // x: 1/w, y: 1/h, z: w, w: h

// Custom fragment shader for high-quality dithering
half4 LitRW_ShadowFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);

    #if defined(_ALPHATEST_ON)
        half4 albedo = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        half alpha = albedo.a * _BaseColor.a;

        // Check if we should be dithering (Transparent Surface Type) or just hard-clipping (Opaque Surface Type)
        #if defined(_SURFACE_TYPE_TRANSPARENT)
            // High-quality Blue Noise Dithering
            // This creates a much more pleasant, less-patterned dissolve effect for shadows.
            float2 blueNoiseUV = input.positionCS.xy * _BlueNoiseTexture_TexelSize.xy;
            half dither = SAMPLE_TEXTURE2D(_BlueNoiseTexture, sampler_BlueNoiseTexture, blueNoiseUV).r;
            
            // Compare the object's alpha to the dither pattern value.
            // As alpha decreases, more and more pixels will be clipped.
            clip(alpha - dither);
        #else
            // Standard alpha clipping for Opaque materials
            clip(alpha - _Cutoff);
        #endif
    #endif

    #if defined(LOD_FADE_CROSSFADE)
        LODFadeCrossFade(input.positionCS);
    #endif

    return 0;
}

#endif