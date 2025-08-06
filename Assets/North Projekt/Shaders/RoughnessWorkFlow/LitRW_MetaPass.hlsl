// LitRW_MetaPass.hlsl
#ifndef LIT_RW_META_PASS_INCLUDED
#define LIT_RW_META_PASS_INCLUDED

// Correct Include Order:
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "LitRW_Shared.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UniversalMetaPass.hlsl"

half4 LitRW_MetaFragment(Varyings input) : SV_Target
{
    SurfaceData surfaceData;
    PopulateCustomSurfaceData(input.uv, half3(0,0,1), surfaceData);

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);
    
    MetaInput metaInput;
    metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
    metaInput.Emission = surfaceData.emission;

    return UniversalFragmentMeta(input, metaInput);
}

#endif