Shader "Unlit/MultiUVFresnel"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [KeywordEnum(UV0, UV1)] _UVSET ("UV Set", Float) = 0

        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower ("Rim Color", Range(0.5, 8)) = 3
        _RimStrength ("Rim Color", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalRenderPipeline" }
        LOD 200

        Pass
        {
            Name "Unlit"
            Tags {"LightMode"="UniversalForward"}

            HLSLPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            #pragma shader_feature_local _UVSET_UV0 _UVSET_UV1
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


            struct Attributes{
                
                float4 positionObj : POSITION;
                float3 normalOS  : NORMAL;

                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };
            struct Varyings{
                float4 positionClip : SV_POSITION;
                
                float2 uv : TEXCOORD0;
                float3 positionWorld : TEXCOORD1;
                float3 normalWorld : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)

                float4 _BaseColor;
                float4 _BaseMap_ST;

                float4 _RimColor;
                float _RimPower;
                float _RimStrength;
            CBUFFER_END

            Varyings vertexShader(Attributes IN){
                Varyings output;

                output.positionWorld = TransformObjectToWorld(IN.positionObj.xyz);
                output.normalWorld = TransformObjectToWorldNormal(IN.normalOS);
                output.positionClip = TransformObjectToHClip(IN.positionObj.xyz);

                #if defined(_UVSET_UV1)
                    output.uv = TRANSFORM_TEX(IN.uv1, _BaseMap);
                #else
                    output.uv = TRANSFORM_TEX(IN.uv0, _BaseMap);
                #endif

                return output;
            }

            half4 fragmentShader(Varyings IN) : SV_TARGET 
            {
                half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                half3 color = baseTex.rgb * _BaseColor.rgb;

                float3 viewDirWorld = SafeNormalize(GetWorldSpaceViewDir(IN.positionWorld));
                
                float3 normal = SafeNormalize(IN.normalWorld);
                float ndotv = saturate(dot(normal, viewDirWorld));
                float fresnel = pow(1.0 - ndotv, _RimPower);
                color += (_RimColor.rgb + fresnel) + _RimStrength;
                
                return half4(color, 1.0);
            }
            
            ENDHLSL
        }
    }

    FallBack Off
}
