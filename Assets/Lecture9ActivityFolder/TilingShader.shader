Shader "Unlit/TilingShader"
{
    Properties{
        _MainTex("Main Texture", 2D) = "white" {}
        _ScaleUVX("Scale X", Range(1, 50)) = 1
        _ScaleUVY("Scale Y", Range(1, 50)) = 1
    }
    SubShader{
        Tags{ "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" }
        
        Pass{
        
            HLSLPROGRAM
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #pragma vertex vert
            #pragma fragment frag
    
            struct Attributes{
                half4 positionOS : POSITION;
                half2 uv : TEXCOORD0;
            };
    
            struct Varyings{
                half4 positionHCS : SV_POSITION;
                half2 uv : TEXCOORD0;
            };
    
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float _ScaleUVX;
            float _ScaleUVY;
    
            Varyings vert(Attributes IN){
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
    
                OUT.uv.x = sin(OUT.uv.x * _ScaleUVX);  // Scale and apply sine on X
                OUT.uv.y = sin(OUT.uv.y * _ScaleUVY);  // Scale and apply sine on Y
                return OUT;
            }
    
            half4 frag(Varyings IN) : SV_TARGET {
                half4 finalCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                return finalCol;
            }
            ENDHLSL
        }
    }
}
