#ifndef UNIVERSAL_HAIR_INPUT_INCLUDED
#define UNIVERSAL_HAIR_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half _BumpScale;
    half _OcclusionStrength;
    half4 _Root_Color, _Length_Color, _Tip_Color;
    half _Root_Distance, _Root_Fade, _Tip_Distance, _Tip_Fade;
    half _PerStrandHueVariation, _PerStrandHueVariationClean, _Going_Grey;
    half _Smoothness, _FresnelStrength;
    half _StrandSeparation, _SpecularFocus, _RimLightStrength, _ShadowContrast, _StrandVisibility, _StrandFrequency, _StrandThreshold;
    half _TransmissionStrength;
    half _Cutoff;
    float4 _HairStrandDirection;
    half _UseCardNormals;
    half _AnisotropicPower, _AnisotropicStrength, _AnisotropicShift;
    half4 _AnisotropicColor;
    half _SecondarySpecularPower, _SecondarySpecularStrength, _SecondarySpecularShift;
    half4 _SecondarySpecularColor;
    half _UsePhysicalSpecularColors;
    
    // Alpha Mode Properties
    half _AlphaMode;
    half _SmoothDither;
    half _DitherStrength;
    half _UseSeparateDepthCutoff;
    half _DepthCutoff;
CBUFFER_END

#ifdef UNITY_DOTS_INSTANCING_ENABLED
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float , _BumpScale)
    UNITY_DOTS_INSTANCED_PROP(float , _OcclusionStrength)
    UNITY_DOTS_INSTANCED_PROP(float4, _Root_Color)
    UNITY_DOTS_INSTANCED_PROP(float4, _Length_Color)
    UNITY_DOTS_INSTANCED_PROP(float4, _Tip_Color)
    UNITY_DOTS_INSTANCED_PROP(float , _Root_Distance)
    UNITY_DOTS_INSTANCED_PROP(float , _Root_Fade)
    UNITY_DOTS_INSTANCED_PROP(float , _Tip_Distance)
    UNITY_DOTS_INSTANCED_PROP(float , _Tip_Fade)
    UNITY_DOTS_INSTANCED_PROP(float , _PerStrandHueVariation)
    UNITY_DOTS_INSTANCED_PROP(float , _PerStrandHueVariationClean)
    UNITY_DOTS_INSTANCED_PROP(float , _Going_Grey)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _FresnelStrength)
    UNITY_DOTS_INSTANCED_PROP(float , _StrandSeparation)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularFocus)
    UNITY_DOTS_INSTANCED_PROP(float , _RimLightStrength)
    UNITY_DOTS_INSTANCED_PROP(float , _ShadowContrast)
    UNITY_DOTS_INSTANCED_PROP(float , _StrandVisibility)
    UNITY_DOTS_INSTANCED_PROP(float , _StrandFrequency)
    UNITY_DOTS_INSTANCED_PROP(float , _StrandThreshold)
    UNITY_DOTS_INSTANCED_PROP(float , _TransmissionStrength)
    UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float4, _HairStrandDirection)
    UNITY_DOTS_INSTANCED_PROP(float , _UseCardNormals)
    UNITY_DOTS_INSTANCED_PROP(float , _AnisotropicPower)
    UNITY_DOTS_INSTANCED_PROP(float , _AnisotropicStrength)
    UNITY_DOTS_INSTANCED_PROP(float , _AnisotropicShift)
    UNITY_DOTS_INSTANCED_PROP(float4, _AnisotropicColor)
    UNITY_DOTS_INSTANCED_PROP(float , _SecondarySpecularPower)
    UNITY_DOTS_INSTANCED_PROP(float , _SecondarySpecularStrength)
    UNITY_DOTS_INSTANCED_PROP(float , _SecondarySpecularShift)
    UNITY_DOTS_INSTANCED_PROP(float4, _SecondarySpecularColor)
    UNITY_DOTS_INSTANCED_PROP(float , _UsePhysicalSpecularColors)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaMode)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothDither)
    UNITY_DOTS_INSTANCED_PROP(float , _DitherStrength)
    UNITY_DOTS_INSTANCED_PROP(float , _UseSeparateDepthCutoff)
    UNITY_DOTS_INSTANCED_PROP(float , _DepthCutoff)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

static float4 unity_DOTS_Sampled_BaseColor;
static float  unity_DOTS_Sampled_BumpScale, unity_DOTS_Sampled_OcclusionStrength;
static float4 unity_DOTS_Sampled_Root_Color, unity_DOTS_Sampled_Length_Color, unity_DOTS_Sampled_Tip_Color;
static float  unity_DOTS_Sampled_Root_Distance, unity_DOTS_Sampled_Root_Fade, unity_DOTS_Sampled_Tip_Distance, unity_DOTS_Sampled_Tip_Fade;
static float  unity_DOTS_Sampled_PerStrandHueVariation, unity_DOTS_Sampled_PerStrandHueVariationClean, unity_DOTS_Sampled_Going_Grey;
static float  unity_DOTS_Sampled_Smoothness, unity_DOTS_Sampled_FresnelStrength;
static float  unity_DOTS_Sampled_StrandSeparation, unity_DOTS_Sampled_SpecularFocus, unity_DOTS_Sampled_RimLightStrength, unity_DOTS_Sampled_ShadowContrast, unity_DOTS_Sampled_StrandVisibility, unity_DOTS_Sampled_StrandFrequency, unity_DOTS_Sampled_StrandThreshold;
static float  unity_DOTS_Sampled_TransmissionStrength;
static float  unity_DOTS_Sampled_Cutoff;
static float4 unity_DOTS_Sampled_HairStrandDirection;
static float  unity_DOTS_Sampled_UseCardNormals;
static float  unity_DOTS_Sampled_AnisotropicPower, unity_DOTS_Sampled_AnisotropicStrength, unity_DOTS_Sampled_AnisotropicShift;
static float4 unity_DOTS_Sampled_AnisotropicColor;
static float  unity_DOTS_Sampled_SecondarySpecularPower, unity_DOTS_Sampled_SecondarySpecularStrength, unity_DOTS_Sampled_SecondarySpecularShift;
static float4 unity_DOTS_Sampled_SecondarySpecularColor;
static float  unity_DOTS_Sampled_UsePhysicalSpecularColors;
static float  unity_DOTS_Sampled_AlphaMode, unity_DOTS_Sampled_SmoothDither;
static float  unity_DOTS_Sampled_DitherStrength;
static float  unity_DOTS_Sampled_UseSeparateDepthCutoff, unity_DOTS_Sampled_DepthCutoff;

void SetupDOTSHairMaterialPropertyCaches(){
    unity_DOTS_Sampled_BaseColor = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _BaseColor);
    unity_DOTS_Sampled_BumpScale = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _BumpScale);
    unity_DOTS_Sampled_OcclusionStrength = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _OcclusionStrength);
    unity_DOTS_Sampled_Root_Color = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _Root_Color);
    unity_DOTS_Sampled_Length_Color = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _Length_Color);
    unity_DOTS_Sampled_Tip_Color = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _Tip_Color);
    unity_DOTS_Sampled_Root_Distance = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _Root_Distance);
    unity_DOTS_Sampled_Root_Fade = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _Root_Fade);
    unity_DOTS_Sampled_Tip_Distance = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _Tip_Distance);
    unity_DOTS_Sampled_Tip_Fade = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _Tip_Fade);
    unity_DOTS_Sampled_PerStrandHueVariation = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _PerStrandHueVariation);
    unity_DOTS_Sampled_PerStrandHueVariationClean = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _PerStrandHueVariationClean);
    unity_DOTS_Sampled_Going_Grey = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _Going_Grey);
    unity_DOTS_Sampled_Smoothness = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _Smoothness);
    unity_DOTS_Sampled_FresnelStrength = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _FresnelStrength);
    unity_DOTS_Sampled_StrandSeparation = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _StrandSeparation);
    unity_DOTS_Sampled_SpecularFocus = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _SpecularFocus);
    unity_DOTS_Sampled_RimLightStrength = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _RimLightStrength);
    unity_DOTS_Sampled_ShadowContrast = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _ShadowContrast);
    unity_DOTS_Sampled_StrandVisibility = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _StrandVisibility);
    unity_DOTS_Sampled_StrandFrequency = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _StrandFrequency);
    unity_DOTS_Sampled_StrandThreshold = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _StrandThreshold);
    unity_DOTS_Sampled_TransmissionStrength = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _TransmissionStrength);
    unity_DOTS_Sampled_Cutoff = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _Cutoff);
    unity_DOTS_Sampled_HairStrandDirection = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _HairStrandDirection);
    unity_DOTS_Sampled_UseCardNormals = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _UseCardNormals);
    unity_DOTS_Sampled_AnisotropicPower = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _AnisotropicPower);
    unity_DOTS_Sampled_AnisotropicStrength = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _AnisotropicStrength);
    unity_DOTS_Sampled_AnisotropicShift = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _AnisotropicShift);
    unity_DOTS_Sampled_AnisotropicColor = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _AnisotropicColor);
    unity_DOTS_Sampled_SecondarySpecularPower = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _SecondarySpecularPower);
    unity_DOTS_Sampled_SecondarySpecularStrength = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _SecondarySpecularStrength);
    unity_DOTS_Sampled_SecondarySpecularShift = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _SecondarySpecularShift);
    unity_DOTS_Sampled_SecondarySpecularColor = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _SecondarySpecularColor);
    unity_DOTS_Sampled_UsePhysicalSpecularColors = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _UsePhysicalSpecularColors);
    unity_DOTS_Sampled_AlphaMode = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _AlphaMode);
    unity_DOTS_Sampled_SmoothDither = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _SmoothDither);
    unity_DOTS_Sampled_DitherStrength = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _DitherStrength);
    unity_DOTS_Sampled_UseSeparateDepthCutoff = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _UseSeparateDepthCutoff);
    unity_DOTS_Sampled_DepthCutoff = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float, _DepthCutoff);
}

#undef UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES
#define UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES() SetupDOTSHairMaterialPropertyCaches()

#define _BaseColor unity_DOTS_Sampled_BaseColor
#define _BumpScale unity_DOTS_Sampled_BumpScale
#define _OcclusionStrength unity_DOTS_Sampled_OcclusionStrength
#define _Root_Color unity_DOTS_Sampled_Root_Color
#define _Length_Color unity_DOTS_Sampled_Length_Color
#define _Tip_Color unity_DOTS_Sampled_Tip_Color
#define _Root_Distance unity_DOTS_Sampled_Root_Distance
#define _Root_Fade unity_DOTS_Sampled_Root_Fade
#define _Tip_Distance unity_DOTS_Sampled_Tip_Distance
#define _Tip_Fade unity_DOTS_Sampled_Tip_Fade
#define _PerStrandHueVariation unity_DOTS_Sampled_PerStrandHueVariation
#define _PerStrandHueVariationClean unity_DOTS_Sampled_PerStrandHueVariationClean
#define _Going_Grey unity_DOTS_Sampled_Going_Grey
#define _Smoothness unity_DOTS_Sampled_Smoothness
#define _FresnelStrength unity_DOTS_Sampled_FresnelStrength
#define _StrandSeparation unity_DOTS_Sampled_StrandSeparation
#define _SpecularFocus unity_DOTS_Sampled_SpecularFocus
#define _RimLightStrength unity_DOTS_Sampled_RimLightStrength
#define _ShadowContrast unity_DOTS_Sampled_ShadowContrast
#define _StrandVisibility unity_DOTS_Sampled_StrandVisibility
#define _StrandFrequency unity_DOTS_Sampled_StrandFrequency
#define _StrandThreshold unity_DOTS_Sampled_StrandThreshold
#define _TransmissionStrength unity_DOTS_Sampled_TransmissionStrength
#define _Cutoff unity_DOTS_Sampled_Cutoff
#define _AnisotropicPower unity_DOTS_Sampled_AnisotropicPower
#define _AnisotropicStrength unity_DOTS_Sampled_AnisotropicStrength
#define _AnisotropicShift unity_DOTS_Sampled_AnisotropicShift
#define _AnisotropicColor unity_DOTS_Sampled_AnisotropicColor
#define _SecondarySpecularPower unity_DOTS_Sampled_SecondarySpecularPower
#define _SecondarySpecularStrength unity_DOTS_Sampled_SecondarySpecularStrength
#define _SecondarySpecularShift unity_DOTS_Sampled_SecondarySpecularShift
#define _SecondarySpecularColor unity_DOTS_Sampled_SecondarySpecularColor
#define _UsePhysicalSpecularColors unity_DOTS_Sampled_UsePhysicalSpecularColors
#define _AlphaMode unity_DOTS_Sampled_AlphaMode
#define _SmoothDither unity_DOTS_Sampled_SmoothDither
#define _DitherStrength unity_DOTS_Sampled_DitherStrength
#define _UseSeparateDepthCutoff unity_DOTS_Sampled_UseSeparateDepthCutoff
#define _DepthCutoff unity_DOTS_Sampled_DepthCutoff
#endif

TEXTURE2D(_OcclusionMap);   SAMPLER(sampler_OcclusionMap);
TEXTURE2D(_NoiseTexture);   SAMPLER(sampler_NoiseTexture);

// Utility function for safe division
half safeDivide(half numerator, half denominator, half fallback) {
    return (abs(denominator) > 0.001) ? (numerator / denominator) : fallback;
}

// Stable noise functions that don't cause temporal artifacts
half GetStableStrandRandom(float2 uv){
    #if defined(_NOISETEXTURE_ON)
        // Use texture sampling for consistent results
        return SAMPLE_TEXTURE2D_LOD(_NoiseTexture, sampler_NoiseTexture, uv * 0.5, 0).r;
    #else
        // Use UV-based hash for stable per-strand randomization
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    #endif
}

// HDRP-style hue shift function for clean color variation
void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
{
    // RGB to HSV
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
    float D = Q.x - min(Q.w, Q.y);
    float E = 1e-10;
    float V = (D == 0) ? Q.x : (Q.x + E);
    float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);

    float hue = hsv.x + Offset;
    hsv.x = (hue < 0)
            ? hue + 1
            : (hue > 1)
                ? hue - 1
                : hue;

    // HSV to RGB
    float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
    Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
}

// Helper function to get the appropriate cutoff for depth/shadow passes
half GetDepthCutoff()
{
    return (_UseSeparateDepthCutoff > 0.5) ? _DepthCutoff : _Cutoff;
}

inline void InitializeHairSurfaceData(float2 uv, float3 positionWS, out SurfaceData outSurfaceData){
    outSurfaceData = (SurfaceData)0;
    
    // Sample the base texture
    half4 baseSample = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    
    // Use stable UV-based randomization to avoid temporal artifacts
    half strandRand = GetStableStrandRandom(uv);
    half v = 1.0 - uv.y;
    
    // Root to tip color gradient
    half3 root = lerp(_Length_Color.rgb, _Root_Color.rgb, smoothstep(_Root_Distance + _Root_Fade, _Root_Distance - _Root_Fade, v));
    half3 tip = lerp(root, _Tip_Color.rgb, smoothstep(1.0 - _Tip_Distance - _Tip_Fade, 1.0 - _Tip_Distance + _Tip_Fade, v));
    half3 albedo = tip * baseSample.rgb * _BaseColor.rgb;
    
    // Per-strand hue variation - dual implementation
    // 1. Noise-based variation (original with stable UV-based randomization)
    if (_PerStrandHueVariation > 0.0) {
        half3 albedoHSV = RgbToHsv(albedo);
        
        // Simple hue shift per strand using stable UV-based hash
        half hueShift = (strandRand - 0.5) * _PerStrandHueVariation;
        
        // Apply hue shift with proper wrapping
        albedoHSV.x = frac(albedoHSV.x + hueShift + 1.0); // +1.0 to handle negative wrapping
        albedo = HsvToRgb(albedoHSV);
    }
    
    // 2. Clean hue variation (HDRP-style without noise)
    if (_PerStrandHueVariationClean > 0.0) {
        // Use UV-based stable offset for consistent per-strand hue variation
        half hueOffset = strandRand * _PerStrandHueVariationClean;
        
        // Apply clean hue shift using HDRP-style function
        half3 hueShiftedColor;
        Unity_Hue_Normalized_float(albedo, hueOffset, hueShiftedColor);
        
        // Lerp between original and hue-shifted color
        albedo = lerp(albedo, hueShiftedColor, _PerStrandHueVariationClean);
    }
    
    // Make strands more visible using alpha-based enhancement with variation
    half alphaStrength = baseSample.a;
    
    // Create stable strand variation pattern using UV coordinates
    half2 strandUV = uv * _StrandFrequency; // Controllable strand frequency
    half strandPattern = sin(strandUV.x * 6.28) * 0.5 + 0.5; // Sine wave pattern for strands
    strandPattern = pow(strandPattern, 2.0); // Make strands more defined
    
    // Combine with stable UV-based noise for more natural variation
    half strandNoise = GetStableStrandRandom(uv * 2.5); // Different scale for variation
    strandPattern = lerp(strandPattern, strandNoise, 0.3);
    
    // Create threshold - only enhance where both alpha AND pattern are strong
    half strandMask = saturate((alphaStrength - _StrandThreshold) / (1.0 - _StrandThreshold));
    strandMask *= saturate((strandPattern - 0.4) / 0.6); // Pattern threshold
    
    // Enhance colors where both conditions are met
    half strandBoost = lerp(0.6, 1.0 + _StrandVisibility * 0.8, strandMask);
    albedo *= strandBoost;
    
    // Add extra contrast for strand definition, but only where strands should be
    half contrastEffect = lerp(0.4, 1.0, _StrandVisibility * 0.5);
    albedo = lerp(albedo * contrastEffect, albedo, strandMask);

    // Going grey effect
    if (strandRand < _Going_Grey) {
        half greyValue = dot(albedo, half3(0.299, 0.587, 0.114));
        albedo = lerp(albedo, greyValue.xxx, saturate(strandRand / max(0.001h, _Going_Grey)));
    }
    
    outSurfaceData.albedo = albedo;
    outSurfaceData.alpha = Alpha(baseSample.a, _BaseColor, _Cutoff);
    outSurfaceData.metallic = 0.0h;
    outSurfaceData.specular = 0.0h;
    outSurfaceData.smoothness = _Smoothness;
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    #ifdef _OCCLUSIONMAP
        outSurfaceData.occlusion = lerp(1.0h, SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g, _OcclusionStrength);
    #else
        outSurfaceData.occlusion = 1.0h;
    #endif
    outSurfaceData.emission = half3(0,0,0);
    outSurfaceData.clearCoatMask = 0.0h;
    outSurfaceData.clearCoatSmoothness = 0.0h;
}

#endif