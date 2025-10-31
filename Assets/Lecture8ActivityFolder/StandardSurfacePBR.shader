Shader "Noah/StandardSurfacePBR"
{
    Properties
    {
        _Color("Metallic", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}

        _MetallicMap ("Metallic Map", 2D) = "white" {}
        
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness("Smmoth", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags {  "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            
            /* ----- STRUCTS ----- */
            struct Attributes{
                float2 uv : TEXCOORD0;
                float3 objSpaceNormal : NORMAL;
                float4 objSpacePos : POSITION;
            };
            struct Varyings{
                
                float2 uv : TEXCOORD0;
                float3 worldSpaceNormal : TEXCOORD1;
                float4 clipSpacePos : SV_POSITION;
            };
            
            // Define texture samplers and material properties
            TEXTURE2D(_MetallicMap);
            SAMPLER(sampler_MetallicMap);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;            // Color property
                float _Metallic;          // Metallic property
                float _Smoothness;        // Smoothness property
            CBUFFER_END

            
            
            /* ----- SHADERS ----- */
            Varyings vertexShader(Attributes IN)
            {
                Varyings OUT;
                OUT.clipSpacePos = TransformObjectToHClip(IN.objSpacePos.xyz);
                OUT.worldSpaceNormal = normalize(TransformObjectToWorldNormal(IN.objSpaceNormal));

                OUT.uv = IN.uv;
                return OUT;
            }

            half4 fragmentShader(Varyings IN) : SV_TARGET
            {
                // Base Col 
                half4 albedoCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;
                
                // Metallic 
                half metallicMapValue = SAMPLE_TEXTURE2D(_MetallicMap, sampler_MetallicMap, IN.uv);
                half metallicValue = lerp(metallicMapValue, _Metallic, _Metallic);

                // Main Light
                Light mainLight = GetMainLight();
                half3 mainLightDir = normalize(mainLight.direction);
                
                // Lambert/Diffuse lighting
                half3 normalWS = IN.worldSpaceNormal;
                half LambertDiffuseValue = saturate(dot(mainLightDir, normalWS));
                half3 diffuse = LambertDiffuseValue * albedoCol;

                // Fresnel
                half3 cameraViewDir = normalize(GetWorldSpaceViewDir(IN.clipSpacePos.xyz));
                half fresnelValue = pow(1 - saturate(dot(cameraViewDir, normalWS)), 5.0);
                
                // Specular
                half3 nearlyBlack = half3(0.04, 0.04, 0.04);
                half3 specular = lerp(nearlyBlack, _Color, metallicValue) * fresnelValue;
                
                // Final Color
                half3 finalColor = diffuse + (specular * _Smoothness);
                return half4(finalColor, 1);
            }

            ENDHLSL
        }
    }
}
