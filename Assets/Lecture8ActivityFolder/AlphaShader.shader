Shader "Noah/Alpha"
{
    Properties{
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Image", 2D) = "white" {}
    }
    SubShader{
        Tags{ "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Transparent" "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass{

            HLSLPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            struct Attributes{
                float2 uv : TEXCOORD0;
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                // half3 positionOS : POSITION
            };

            struct Varyings{
                float2 uv : TEXCOORD0;
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                // half3 positionOS : POSITION
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
            CBUFFER_END


            Varyings vertexShader(Attributes IN){
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 fragmentShader(Varyings IN) : SV_TARGET
            {

                half4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;

                //Main Light
                Light mainLight = GetMainLight();
                half3 mainLightDir = normalize(mainLight.direction);

                //Diffuse
                half4 diffuseValue = saturate(dot(mainLightDir, IN.normalWS));

                half4 finalColor = half4(diffuseValue.xyz + baseColor.xyz, baseColor.w);
                return finalColor;
            }

            ENDHLSL
        }
    }
}