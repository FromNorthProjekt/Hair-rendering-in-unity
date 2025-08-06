// LitRW_Shared.hlsl
#ifndef LIT_RW_SHARED_INCLUDED
#define LIT_RW_SHARED_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"

TEXTURE2D(_RoughnessMap);       SAMPLER(sampler_RoughnessMap);
TEXTURE2D(_MetallicMap);        SAMPLER(sampler_MetallicMap);

void PopulateCustomSurfaceData(float2 uv, half3 viewDirTS, out SurfaceData surfaceData)
{
    surfaceData = (SurfaceData)0;

    #if defined(_PARALLAXMAP)
        uv += ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirTS, _Parallax, uv);
    #endif

    half4 albedoPacked = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    surfaceData.albedo = albedoPacked.rgb * _BaseColor.rgb;
    surfaceData.alpha = Alpha(albedoPacked.a, _BaseColor, _Cutoff);

    #if defined(_NORMALMAP)
        surfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    #else
        surfaceData.normalTS = half3(0.0h, 0.0h, 1.0h);
    #endif

    #if defined(_OCCLUSIONMAP)
        half occlusionSample = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).r;
        surfaceData.occlusion = lerp(1.0h, occlusionSample, _OcclusionStrength);
    #else
        surfaceData.occlusion = 1.0h;
    #endif
    
    #if defined(_EMISSION)
        half3 emissionSample = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb;
        surfaceData.emission = emissionSample * _EmissionColor.rgb;
    #else
        surfaceData.emission = half3(0.0h, 0.0h, 0.0h);
    #endif

    // --- ROUGHNESS TO SMOOTHNESS CONVERSION ---
    half roughnessFromMap = 1.0h; // Default to 1 (no roughness) if no map
    #if defined(_ROUGHNESSMAP_ON)
        roughnessFromMap = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap, uv).r;
    #endif
    
    half uiRoughnessScalar = 1.0h - _Smoothness;
    half combinedRoughness = roughnessFromMap * uiRoughnessScalar;
    half calculatedSmoothness = 1.0h - combinedRoughness;
    // ---

#if defined(_SPECULAR_SETUP)
    surfaceData.metallic = 0.0h;
    surfaceData.specular = _SpecColor.rgb;
    surfaceData.smoothness = calculatedSmoothness;
#else
    #if defined(_METALLICMAP_ON)
        half metallicFromMap = SAMPLE_TEXTURE2D(_MetallicMap, sampler_MetallicMap, uv).r;
        surfaceData.metallic = metallicFromMap * _Metallic;
    #else
        surfaceData.metallic = _Metallic;
    #endif
    surfaceData.specular = half3(0.0h, 0.0h, 0.0h);
    surfaceData.smoothness = calculatedSmoothness;
#endif
}

#endif