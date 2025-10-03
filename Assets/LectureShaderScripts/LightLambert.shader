Shader "URPTextureShader/woah"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _HighShade ("Highlights", Float) = 1
        _MidShade ("Midtones", Float) = 1
        _LowShade ("Shadows", Float) = 1
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;    
                float3 normalOS : NORMAL; 
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);     
            SAMPLER(sampler_MainTex); 

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;   
                float4 _HighShade;   
                float4 _MidShade;   
                float4 _LowShade;   
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);       
                OUT.uv = IN.uv;                                               
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS)); 
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
               
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                
                
                half3 finalColor = texColor.rgb * _BaseColor.rgb;

               
                half3 normal = normalize(IN.normalWS);
                Light mainLight = GetMainLight();                      
                half3 lightDir = normalize(mainLight.direction);
                half NdotL = saturate(dot(normal, lightDir));     

                half low = 0.2f;          
                half mid = 0.6f;          
                
                half3 posterizedColorSample; 

                #if (NdotL < low)
                    posterizedColorSample = finalColor;
                    // posterizedColorSample = finalColor * _LowShade;
                    return half4(posterizedColorSample);                 
                    #endif
                #if (NdotL < mid)
                    posterizedColorSample = finalColor;
                    // posterizedColorSample = finalColor * _MidShade;
                    return half4(posterizedColorSample);                 
                    #endif
                    
                    posterizedColorSample = finalColor;
                    // posterizedColorSample = finalColor * _HighShade;
                // return half4(posterizedColorSample, 1.0);                 
                return half4(posterizedColorSample, 1.0);                 
                    
            }
            ENDHLSL
        }
    }
}