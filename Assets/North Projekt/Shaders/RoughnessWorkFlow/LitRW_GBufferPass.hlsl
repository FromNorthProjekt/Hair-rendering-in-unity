// LitRW_GBufferPass.hlsl
#ifndef LIT_RW_GBUFFER_PASS_INCLUDED
#define LIT_RW_GBUFFER_PASS_INCLUDED

// Correct Include Order:
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "LitRW_Shared.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitGBufferPass.hlsl"

// --- IMPLEMENTATION ---
GBufferFragOutput LitRW_GBufferFragment(Varyings input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #if defined(_PARALLAXMAP)
    #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = input.viewDirTS;
    #else
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, viewDirWS);
    #endif
    #else
    half3 viewDirTS = half3(0, 0, 1);
    #endif

    SurfaceData surfaceData;
    PopulateCustomSurfaceData(input.uv, viewDirTS, surfaceData);

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    InitializeBakedGIData(input, inputData);

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);
    
    half3 color = GlobalIllumination(brdfData, (BRDFData)0, 0.0h,
                                      inputData.bakedGI, surfaceData.occlusion, 
                                      inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS,
                                      inputData.normalizedScreenSpaceUV);
                                      
    return PackGBuffersBRDFData(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color, surfaceData.occlusion);
}

#endif