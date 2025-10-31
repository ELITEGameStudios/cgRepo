Shader "Unlit/MultiUV"
{
    Properties
    {
        _Scale ("Scale", Float) = 1
        _Offset ("Offset", Vector) = (0, 0, 0, 0)
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
            };
            struct Varyings{
                float4 positionClip : SV_POSITION;
                float3 positionWorld : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float _Scale;
                float4 _Offset;
            CBUFFER_END

            Varyings vertexShader(Attributes IN){
                Varyings output;
                float3 positionWorld = TransformObjectToWorld(IN.positionObj.xyz);
                output.positionWorld = positionWorld;
                output.positionClip = TransformWorldToHClip(positionWorld);

                return output;
            }

            float3 WorldPosToColor(float3 worldPos, float scale){
                float3 position = worldPos * max(scale, 1e-4);
                float3 base = frac(position);
                float3 edge = step(0.98, frac(position));
                return saturate(base + edge * 0.2);
            }

            half4 fragmentShader(Varyings IN) : SV_TARGET 
            {
                float3 wp = IN.positionWorld + _Offset.xyz;
                float3 col = WorldPosToColor(wp, _Scale);
                return half4(col, 1);
            }
            
            ENDHLSL
        }
    }

    FallBack Off
}
