// LitRW_ForwardPass.hlsl
#ifndef LIT_RW_FORWARD_PASS_INCLUDED
#define LIT_RW_FORWARD_PASS_INCLUDED

// Correct Include Order:
// 1. LitInput: Declares all material properties and the SurfaceData struct.
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
// 2. Our Shared file: Contains our custom logic that USES the properties from LitInput.
#include "LitRW_Shared.hlsl"
// 3. The URP pass logic: Contains the vertex/fragment functions we will use/override.
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitForwardPass.hlsl"

// --- IMPLEMENTATION ---
half4 LitRW_ForwardFragment(Varyings input) : SV_Target
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

    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(input.positionCS);
    #endif

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);

    #if defined(_DBUFFER)
        ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
    #endif
        
    InitializeBakedGIData(input, inputData);

    half4 color = UniversalFragmentPBR(inputData, surfaceData);
    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, IsSurfaceTypeTransparent(_Surface));

    #ifdef _WRITE_RENDERING_LAYERS
        uint renderingLayers = GetMeshRenderingLayer();
        float4 outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
    #endif

    return color;
}

#endif