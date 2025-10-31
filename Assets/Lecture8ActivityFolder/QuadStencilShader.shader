Shader "Noah/QuadStencilShader"
{
    Properties{

    }
    SubShader{
        
        
        Tags{ "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Geometry" }

        ColorMask 0
        ZWrite Off
        
        Stencil{
            Ref 1
            Comp Always
            Pass Replace
        }
        
        Pass{
            HLSLPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            
            struct Attributes{
                float4 positionOS : POSITION;
            };
            struct Varyings{
                float4 positionWS : SV_POSITION;
            };

            Varyings vertexShader(Attributes IN){
                Varyings OUT;
                OUT.positionWS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 fragmentShader(Varyings IN) : SV_TARGET{
                return half4(0, 0, 0, 1);
            }

            ENDHLSL
        }
    }
}
