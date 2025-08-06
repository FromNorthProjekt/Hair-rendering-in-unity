Shader "Custom/TransparentDepthOnly"
{
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

               Pass
        {
            Tags { "LightMode"="SRPDefaultUnlit" } // Added for better compatibility
            ColorMask 0
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // This is the key pragma that creates the DOTS_INSTANCING_ON variant
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                // The vertex shader needs to receive the instance ID from the GPU
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                // This macro must be called at the start of the vertex shader.
                // It sets up the per-instance data (like transformation matrices).
                UNITY_SETUP_INSTANCE_ID(IN);

                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }
    }
}