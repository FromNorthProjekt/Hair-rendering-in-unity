Shader "North Projekt/Hair (Kajiya Kay)"
{
    Properties
    {
       [Header(Surface Inputs)]
        [MainTexture] _BaseMap("Albedo (RGB) Alpha (A)", 2D) = "white" {}
        [MainColor] _BaseColor("Albedo Tint", Color) = (1,1,1,1)
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Float) = 1.0
        _OcclusionMap("Occlusion Map (G)", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0
        [Toggle(_NOISETEXTURE_ON)] _UseNoiseTexture("Enable Noise Variation", Float) = 1.0
        _NoiseTexture("Variation Noise Map (R)", 2D) = "grey" {}

        [Header(Color Gradient and Control)]
        _Root_Color("Root Color", Color) = (0.1, 0.1, 0.1, 1)
        _Length_Color("Length Color", Color) = (0.5, 0.3, 0.1, 1)
        _Tip_Color("Tip Color", Color) = (0.9, 0.7, 0.4, 1)
        _Root_Distance("Root Distance", Range(0, 1)) = 0.1
        _Root_Fade("Root Fade", Range(0.01, 1)) = 0.1
        _Tip_Distance("Tip Distance", Range(0, 1)) = 0.2
        _Tip_Fade("Tip Fade", Range(0.01, 1)) = 0.2

        [Header(Strand Level Variation)]
        _PerStrandHueVariationClean("Per Strand Hue Variation", Range(0, 1)) = 0.01
        _PerStrandHueVariation("Per Strand Hue Variation (Noise)", Range(0, 1)) = 0.05
        _Going_Grey("Going Grey Threshold", Range(0, 1)) = 0.0

        [Header(Kajiya Kay Lighting Model)] 
        _Smoothness("Smoothness", Range(0, 1)) = 0.8
        _FresnelStrength("Fresnel Strength", Range(0, 1)) = 0.25
        _HairStrandDirection("Hair Strand Direction", Vector) = (0, -1, 0, 0)
        [Toggle] _UseCardNormals("Use Card Normals", Float) = 0
        
        [Header(Hair Quality Controls)]
        _StrandSeparation("Strand Separation", Range(0, 1)) = 0.3
        _SpecularFocus("Specular Focus", Range(0.1, 2)) = 1.0
        _RimLightStrength("Rim Light Strength", Range(0, 2)) = 0.5
        _ShadowContrast("Shadow Contrast", Range(1, 3)) = 1.5
        _StrandVisibility("Strand Visibility", Range(0, 2)) = 1.0
        _StrandFrequency("Strand Frequency", Range(10, 100)) = 50.0
        _StrandThreshold("Strand Threshold", Range(0, 1)) = 0.3

        [Header(Anisotropic Specular)]
        _AnisotropicPower("Anisotropic Power", Range(1, 1000)) = 64
        _AnisotropicStrength("Anisotropic Strength", Range(0, 1)) = 0.1
        _AnisotropicShift("Anisotropic Shift", Range(-1, 1)) = 0.0
        _AnisotropicColor("Anisotropic Color", Color) = (1,1,1,1)
        _SecondarySpecularPower("Secondary Specular Power", Range(1, 1000)) = 128
        _SecondarySpecularStrength("Secondary Specular Strength", Range(0, 1)) = 0.1
        _SecondarySpecularShift("Secondary Specular Shift", Range(-1, 1)) = 0.3
        _SecondarySpecularColor("Secondary Specular Color", Color) = (0.8,0.6,0.4,1)
        [Toggle(_USE_PHYSICAL_SPECULAR_COLORS)] _UsePhysicalSpecularColors("Use Physical Specular Colors", Float) = 0

        [Header(Transmission)]
        _TransmissionStrength("Strength", Range(0, 5)) = 0.5

        // System Properties
        [Header(Alpha Mode)]
        [KeywordEnum(Clip, ClipWithAlpha, Alpha)] _AlphaMode("Alpha Mode", Float) = 0
        [Toggle(_SMOOTH_DITHER_ON)] _SmoothDither("Smooth Dither (Clip Mode)", Float) = 1.0
        _DitherStrength("Dither Strength", Range(0.1, 2.0)) = 0.8
        
        [Header(System Settings)]
        _Cutoff("Alpha Cutoff (Main Pass)", Range(0.0, 1.0)) = 0.5
        [Toggle] _UseSeparateDepthCutoff("Use Separate Depth Cutoff", Float) = 0.0
        _DepthCutoff("Alpha Cutoff (Depth/Shadow Passes)", Range(0.0, 1.0)) = 0.3
        _Cull("__cull", Float) = 0.0      // Cull Off
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }

        // Pass 1: Custom Depth Pre-Pass (Inlined)
        Pass
        {
            Name "Custom_TransparentDepthPrepass"
            Tags { "LightMode" = "Custom_TransparentDepthPrepass" }
            ZWrite On ColorMask 0 Cull [_Cull]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "HairInput.hlsl" // Include shared properties

            struct Attributes {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct Varyings { float4 positionCS : SV_POSITION; float2 uv : TEXCOORD0; };

            Varyings vert (Attributes IN) {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }
            half4 frag (Varyings IN) : SV_Target {
                half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv).a;
                clip(alpha - GetDepthCutoff());
                return 0;
            }
            ENDHLSL
        }

        // Pass 2: Main Forward Lit Pass (Using Includes)
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull [_Cull]

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _OCCLUSIONMAP
            #pragma shader_feature_local _NOISETEXTURE_ON
            #pragma shader_feature_local _SMOOTH_DITHER_ON
            #pragma shader_feature_local _USE_CARD_NORMALS_ON
            #pragma shader_feature_local _USE_PHYSICAL_SPECULAR_COLORS
            #pragma shader_feature_local _ALPHAMODE_CLIP _ALPHAMODE_CLIPWITHALPHA _ALPHAMODE_ALPHA
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_instancing

            #include "HairInput.hlsl"
            #include "HairForwardPass.hlsl"
            
            ENDHLSL
        }

        // Pass 3: Shadow Caster Pass (Inlined)
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On ZTest LEqual ColorMask 0 Cull [_Cull]

            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile_instancing
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "HairInput.hlsl" // Include shared properties

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            float3 _LightDirection;
            float3 _LightPosition;

            Varyings ShadowPassVertex(Attributes input) {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
                #if UNITY_REVERSED_Z
                    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #else
                    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #endif
                output.positionCS = positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET {
                half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a * _BaseColor.a;
                clip(alpha - GetDepthCutoff());
                return 0;
            }
            ENDHLSL
        }

        // Pass 4: Depth Only Pass (Inlined)
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ZWrite On ColorMask R Cull [_Cull]

            HLSLPROGRAM
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "HairInput.hlsl" // Include shared properties

            struct Attributes {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            Varyings DepthOnlyVertex(Attributes input) {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET {
                half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a * _BaseColor.a;
                clip(alpha - GetDepthCutoff());
                return 0;
            }
            ENDHLSL
        }
    }
    
    CustomEditor "RED.Editor.Inspectors.Shaders.HairShaderGUI" 
}