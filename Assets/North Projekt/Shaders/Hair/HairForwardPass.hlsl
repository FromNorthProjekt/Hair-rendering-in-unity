#ifndef HAIR_FORWARD_PASS_INCLUDED
#define HAIR_FORWARD_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float3 positionWS               : TEXCOORD1;
    half3 normalWS                  : TEXCOORD2;
    half4 tangentWS                 : TEXCOORD3;
    half4 fogFactorAndVertexLight   : TEXCOORD5;
    float4 shadowCoord              : TEXCOORD6;
    // REMOVED: windOffset is no longer needed.
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD9;
#endif
#ifdef USE_APV_PROBE_OCCLUSION
    float4 probeOcclusion : TEXCOORD10;
#endif
    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

half3 HairLighting(Light light, half smoothness, half3 albedo, half3 N, half3 T, half3 V, half3 B, float2 uv)
{
    half3 L = light.direction;
    half3 H = normalize(L + V);
    half NdotL = saturate(dot(N, L));
    half VdotN = saturate(dot(V, N));
    
    // Physically correct diffuse using Lambert's cosine law
    // For hair, we use wrapped lighting to simulate subsurface scattering
    half wrappedNdotL = saturate((NdotL + 0.3) / 1.3); // Wrap lighting coefficient
    
    // Apply shadow contrast to enhance strand separation
    half shadowContrastEffect = pow(wrappedNdotL, _ShadowContrast);
    
    // Create stable strand separation effect using UV coordinates
    half strandNoise = frac(sin(dot(uv * 50.0, float2(12.9898, 78.233))) * 43758.5453);
    half strandMask = lerp(1.0, saturate(strandNoise + 0.3), _StrandSeparation);
    
    // Physically correct diffuse: albedo * NdotL / π (π is baked into light intensity)
    half3 diffuse = albedo * shadowContrastEffect * strandMask;
    
    // Calculate hair strand direction for anisotropic highlights
    #ifdef _USE_CARD_NORMALS_ON
    // Use card normals for automatic specular highlights
    // For hair cards: T = along hair flow, B = across hair flow
    // Anisotropic highlights should run perpendicular to hair flow
    half3 hairStrandWS = normalize(B);  // Try B for across-hair highlights
    // If above doesn't work, try: half3 hairStrandWS = normalize(T); // for along-hair highlights
    #else
    // Use manual hair strand direction
    half3 hairStrandWS = normalize(T * _HairStrandDirection.x + 
                                B * _HairStrandDirection.y + 
                                N * _HairStrandDirection.z);
    #endif
    
    
    // Primary specular highlight with improved focus control
    half3 shiftedTangent1 = normalize(hairStrandWS + N * _AnisotropicShift);
    half dotTH1 = dot(shiftedTangent1, H);
    half sinTH1 = sqrt(max(0.01, 1.0 - dotTH1 * dotTH1));
    
    // Enhanced directional attenuation with specular focus control
    half focusRange = lerp(0.3, 1.2, _SpecularFocus);
    half dirAtten1 = smoothstep(-focusRange, focusRange * 0.5, dotTH1);
    
    // Improved smoothness application - creates more natural falloff
    half effectivePower1 = lerp(8.0, _AnisotropicPower * 2.0, smoothness);
    half spec1 = dirAtten1 * pow(sinTH1, effectivePower1);
    
    // Add strand separation to specular for more realistic hair look
    spec1 *= strandMask;
    
    // Primary specular color - physically based vs manual
    #ifdef _USE_PHYSICAL_SPECULAR_COLORS
    // In physical mode, primary specular reflects light color (applied later)
    half3 primarySpecular = half3(1.0, 1.0, 1.0) * _AnisotropicStrength * spec1;
    #else
    half3 primarySpecular = _AnisotropicColor.rgb * _AnisotropicStrength * spec1;
    #endif
    
    // Secondary specular with different characteristics for realism
    half3 shiftedTangent2 = normalize(hairStrandWS + N * _SecondarySpecularShift);
    half dotTH2 = dot(shiftedTangent2, H);
    half sinTH2 = sqrt(max(0.01, 1.0 - dotTH2 * dotTH2));
    
    // Secondary specular is softer and more distributed
    half focusRange2 = lerp(0.5, 1.0, _SpecularFocus * 0.7);
    half dirAtten2 = smoothstep(-focusRange2, focusRange2 * 0.3, dotTH2);
    
    half effectivePower2 = lerp(16.0, _SecondarySpecularPower * 1.5, smoothness);
    half spec2 = dirAtten2 * pow(sinTH2, effectivePower2);
    
    // Secondary specular is less affected by strand separation for softer look
    spec2 *= lerp(1.0, strandMask, 0.5);
    
    // Secondary specular color - physically based vs manual
    #ifdef _USE_PHYSICAL_SPECULAR_COLORS
    half3 secondarySpecular = albedo * _SecondarySpecularStrength * spec2;
    #else
    half3 secondarySpecular = _SecondarySpecularColor.rgb * _SecondarySpecularStrength * spec2;
    #endif
    
    // Rim lighting for better hair edge definition
    half rimFactor = 1.0 - VdotN;
    half rimLight = pow(rimFactor, 3.0) * _RimLightStrength;
    half3 rimContribution = albedo * rimLight;
    
    // Enhanced Fresnel with better energy distribution
    half VdotH = saturate(dot(V, H));
    half fresnel = _FresnelStrength + (1.0 - _FresnelStrength) * pow(1.0 - VdotH, 2.0);
    
    // Combine specular highlights
    half3 totalSpecular = primarySpecular + secondarySpecular;
    
    // Proper energy conservation - specular energy should be subtracted from diffuse
    // Convert specular to luminance for energy conservation
    half specularLuminance = dot(totalSpecular, half3(0.299, 0.587, 0.114));
    half energyConservation = saturate(1.0 - specularLuminance);
    half3 conservedDiffuse = diffuse * energyConservation;
    
    // Apply fresnel to specular only (more physically correct)
    totalSpecular *= fresnel;
    
    // Combine lighting components without double light color multiplication
    half3 directLighting = conservedDiffuse + totalSpecular;
    
    // Add rim lighting as additional diffuse contribution
    directLighting += rimContribution;
    
    // Add transmission (subsurface scattering) - physically based
    half VdotL = dot(V, -L); // View dot with negative light direction
    half transmission = _TransmissionStrength * saturate(VdotL) * NdotL;
    directLighting += albedo * transmission;
    
    // Apply light color and attenuation properly (only once)
    return directLighting * light.color * light.shadowAttenuation;
}

half4 HairFragmentPBR(InputData inputData, SurfaceData surfaceData, float2 uv)
{
    half3 finalColor = 0;
    Light mainLight = GetMainLight(inputData.shadowCoord);
    
    // Calculate bitangent for proper hair strand direction
    half3 tangentWS = normalize(inputData.tangentToWorld[0]);
    half3 bitangentWS = normalize(inputData.tangentToWorld[1]);
    
    finalColor += HairLighting(mainLight, surfaceData.smoothness, surfaceData.albedo, inputData.normalWS, tangentWS, inputData.viewDirectionWS, bitangentWS, uv);
    #ifdef _ADDITIONAL_LIGHTS
        uint pixelLightCount = GetAdditionalLightsCount();
        for (uint i = 0u; i < pixelLightCount; ++i)
        {
            Light addLight = GetAdditionalLight(i, inputData.positionWS);
            finalColor += HairLighting(addLight, surfaceData.smoothness, surfaceData.albedo, inputData.normalWS, tangentWS, inputData.viewDirectionWS, bitangentWS, uv);
        }
    #endif
    
    // Add indirect lighting (GI)
    half3 indirectDiffuse = inputData.bakedGI * surfaceData.albedo;
    finalColor += indirectDiffuse * surfaceData.occlusion;
    
    return half4(finalColor, surfaceData.alpha);
}

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData){
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS;
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    float sgn = input.tangentWS.w;
    half3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
    inputData.tangentToWorld = tangentToWorld;
    inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;
    inputData.shadowCoord = input.shadowCoord;
    inputData.fogCoord = input.fogFactorAndVertexLight.x;
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
}

void InitializeBakedGIData(Varyings input, inout InputData inputData){
    #if defined(DYNAMICLIGHTMAP_ON)
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
    #elif !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
    inputData.bakedGI = SAMPLE_GI(input.vertexSH, GetAbsolutePositionWS(inputData.positionWS), inputData.normalWS, inputData.viewDirectionWS, input.positionCS.xy, input.probeOcclusion, inputData.shadowMask);
    #else
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
    #endif
}

Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.normalWS = normalInput.normalWS;
    real sign = input.tangentOS.w * GetOddNegativeScale();
    output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
    OUTPUT_SH4(vertexInput.positionWS, output.normalWS.xyz, viewDirWS, output.vertexSH, output.probeOcclusion);
    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    output.positionWS = vertexInput.positionWS;
    output.shadowCoord = GetShadowCoord(vertexInput);
    output.positionCS = vertexInput.positionCS;
    return output;
}

half ResolveAlpha(half alpha)
{
        //        half saferPower =  abs( saturate( ( baseSample.a / 0.75 ) ) );
        //        half finalAlpha = pow(saferPower, 1);

        half saferPower = abs(saturate((alpha / 0.75)));
        half finalAlpha = pow(saferPower, 1);
        return finalAlpha;
}

void LitPassFragment(Varyings input, out half4 outColor : SV_Target0){
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    SurfaceData surfaceData;
    // Initialize surface data
    InitializeHairSurfaceData(input.uv, input.positionWS, surfaceData);
    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    InitializeBakedGIData(input, inputData);
    half4 color = HairFragmentPBR(inputData, surfaceData, input.uv);
    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    
    // Alpha Mode: 0 = Clip, 1 = ClipWithAlpha, 2 = Alpha
    half finalAlpha = 1.0;
    
    #if defined(_ALPHAMODE_CLIP)
        // Mode 0: Clip only, return alpha = 1
        #if defined(_SMOOTH_DITHER_ON)
            // Improved dither implementation to reduce white dot noise
            float dither = InterleavedGradientNoise(input.positionCS.xy, 0);
            
            // Apply temporal dithering with frame index for better distribution
            float temporalDither = InterleavedGradientNoise(input.positionCS.xy, _Time.y * 60.0);
            dither = lerp(dither, temporalDither, 0.1);
            
            // Smooth the dither pattern to reduce harsh transitions
            dither = smoothstep(0.0, 1.0, dither);
            
            // Apply a bias to reduce noise in mid-alpha ranges
            float alphaBias = 0.1;
            float adjustedAlpha = saturate(surfaceData.alpha + alphaBias);
            
            // Use controllable dither strength instead of fixed 0.8
            clip(adjustedAlpha - dither * _DitherStrength);
        #else
            // Standard alpha clipping for clean, traditional transparency
            clip(surfaceData.alpha - _Cutoff);
        #endif
        finalAlpha = 1.0;
    #elif defined(_ALPHAMODE_CLIPWITHALPHA)
        // Mode 1: Clip and return true alpha
       finalAlpha = ResolveAlpha(surfaceData.alpha);
       clip(finalAlpha - _Cutoff);
    #else
        // Mode 2: Alpha only, no clipping
        finalAlpha = ResolveAlpha(surfaceData.alpha);
    #endif
    
    outColor = half4(color.rgb, finalAlpha);
}
#endif