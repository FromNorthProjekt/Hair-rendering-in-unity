// LitRW_DepthNormalsPass.hlsl
#ifndef LIT_RW_DEPTHNORMALS_PASS_INCLUDED
#define LIT_RW_DEPTHNORMALS_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"

// All keywords are defined in the .shader file.
// We can directly use the URP functions as they handle parallax and normal mapping.
// Our custom PBR logic does not affect the depth/normal output.

#endif