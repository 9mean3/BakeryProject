// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "1_fx/shokewave"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_Src("Src", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_Dst("Dst", Float) = 10
		_Main_Texture("Main_Texture", 2D) = "white" {}
		[HDR]_TintColor("Tint Color", Color) = (1,1,1,0)
		_Main_UPanner("Main_UPanner", Float) = 0
		_Main_VPanner("Main_VPanner", Float) = 0.39
		_Main_Ins("Main_Ins", Range( 1 , 10)) = 1
		_Main_Pow("Main_Pow", Range( 1 , 10)) = 1
		_Opacity("Opacity", Range( 0 , 10)) = 1
		_Fade_Distance("Fade_Distance", Float) = 0
		_Noise_Texture("Noise_Texture", 2D) = "bump" {}
		_Noise_Str("Noise_Str", Range( 0 , 0.3)) = 0.06793601
		_Noise_Tex_UPanner("Noise_Tex_UPanner", Float) = 0
		_Noise_Tex_VPanner("Noise_Tex_VPanner", Float) = 0
		_Diss_Texture("Diss_Texture", 2D) = "white" {}
		_Dissolve("Dissolve", Range( -1 , 1)) = 0
		[Toggle(USE_CUSTOM_ON)] Use_Custom("Use_Custom", Float) = 0
		_Diss_Tex_UPanner("Diss_Tex_UPanner", Float) = 0
		_Diss_Tex_VPanner("Diss_Tex_VPanner", Float) = 0
		_Sub_Texture("Sub_Texture", 2D) = "white" {}
		[HDR]_SubTex_Color("SubTex_Color", Color) = (0,0,0,0)
		_SubTex_Ins("SubTex_Ins", Range( 0 , 10)) = 0
		_SubTex_Pow("SubTex_Pow", Range( 1 , 10)) = 0
		_SubTex_UPanner("SubTex_UPanner", Float) = 0
		_SubTex_VPanner("SubTex_VPanner", Float) = 0
		_Mask_Texture("Mask_Texture", 2D) = "white" {}
		[Toggle(_USE_MASKTEX_ON)] _Use_MaskTex("Use_MaskTex", Float) = 0
		[Toggle(_MASK_1X_ON)] _Mask_1x("Mask_-1x", Float) = 0
		_Mask_Pow("Mask_Pow", Range( 1 , 50)) = 5.346326
		[Toggle(_MASK_MIRROR_ON)] _Mask_Mirror("Mask_Mirror", Float) = 1
		[Toggle(_USE_ADDMULITYMASK_ON)] _Use_AddMulityMask("Use_AddMulityMask", Float) = 0
		[Toggle(_USE_CEIL_ON)] _Use_Ceil("Use_Ceil", Float) = 0
		_Ceil("Ceil", Float) = 0
		_Vertex_texture("Vertex_texture", 2D) = "white" {}
		_vertex_upanner("vertex_upanner", Float) = 0
		_vertex_vpanner("vertex_vpanner", Float) = 0
		_vertex_pow("vertex_pow", Float) = 3.71
		_vertex_str("vertex_str", Float) = 0
		[ASEEnd][Toggle(_USE_VERTEX_ON)] _Use_vertex("Use_vertex", Float) = 0


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull [_CullMode]
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend [_Src] [_Dst], [_Src] [_Dst]
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma instancing_options renderinglayer

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        	#pragma multi_compile_fragment _ DEBUG_DISPLAY
        	#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        	#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _USE_VERTEX_ON
			#pragma shader_feature_local _USE_CEIL_ON
			#pragma shader_feature_local USE_CUSTOM_ON
			#pragma shader_feature_local _USE_ADDMULITYMASK_ON
			#pragma shader_feature_local _USE_MASKTEX_ON
			#pragma shader_feature_local _MASK_MIRROR_ON
			#pragma shader_feature_local _MASK_1X_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Noise_Texture_ST;
			float4 _Diss_Texture_ST;
			float4 _TintColor;
			float4 _SubTex_Color;
			float4 _Main_Texture_ST;
			float4 _Sub_Texture_ST;
			float _Noise_Tex_VPanner;
			float _Noise_Str;
			float _Ceil;
			float _Main_Pow;
			float _Main_Ins;
			float _Opacity;
			float _Diss_Tex_UPanner;
			float _Diss_Tex_VPanner;
			float _Dissolve;
			float _Noise_Tex_UPanner;
			float _Src;
			float _Main_VPanner;
			float _Main_UPanner;
			float _SubTex_Ins;
			float _SubTex_Pow;
			float _SubTex_VPanner;
			float _SubTex_UPanner;
			float _vertex_str;
			float _vertex_pow;
			float _vertex_vpanner;
			float _vertex_upanner;
			float _CullMode;
			float _Dst;
			float _Mask_Pow;
			float _Fade_Distance;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Vertex_texture;
			sampler2D _Sub_Texture;
			sampler2D _Main_Texture;
			sampler2D _Noise_Texture;
			sampler2D _Diss_Texture;
			sampler2D _Mask_Texture;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult171 = (float2(_vertex_upanner , _vertex_vpanner));
				float2 texCoord167 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner168 = ( 1.0 * _Time.y * appendResult171 + texCoord167);
				#ifdef _USE_VERTEX_ON
				float3 staticSwitch180 = ( v.ase_normal * ( saturate( pow( tex2Dlod( _Vertex_texture, float4( panner168, 0, 0.0) ).r , _vertex_pow ) ) * _vertex_str ) );
				#else
				float3 staticSwitch180 = float3( 0,0,0 );
				#endif
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch180;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
				#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
				#endif
				 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 appendResult97 = (float2(_SubTex_UPanner , _SubTex_VPanner));
				float2 uv_Sub_Texture = IN.ase_texcoord3.xy * _Sub_Texture_ST.xy + _Sub_Texture_ST.zw;
				float2 panner92 = ( 1.0 * _Time.y * appendResult97 + uv_Sub_Texture);
				float2 appendResult7 = (float2(_Main_UPanner , _Main_VPanner));
				float2 uv_Noise_Texture = IN.ase_texcoord3.xy * _Noise_Texture_ST.xy + _Noise_Texture_ST.zw;
				float2 appendResult32 = (float2(_Noise_Tex_UPanner , _Noise_Tex_VPanner));
				float2 uv_Main_Texture = IN.ase_texcoord3.xy * _Main_Texture_ST.xy + _Main_Texture_ST.zw;
				float2 temp_output_28_0 = ( ( (UnpackNormalScale( tex2D( _Noise_Texture, (uv_Noise_Texture*1.0 + ( appendResult32 * _TimeParameters.x )) ), 1.0f )).xy * _Noise_Str ) + uv_Main_Texture );
				float2 panner130 = ( 1.0 * _Time.y * appendResult7 + temp_output_28_0);
				float main_r_ref144 = tex2D( _Main_Texture, panner130 ).r;
				float2 temp_cast_0 = (main_r_ref144).xx;
				float temp_output_2_0_g1 = _Ceil;
				#ifdef _USE_CEIL_ON
				float staticSwitch131 = (( ceil( ( temp_cast_0 * temp_output_2_0_g1 ) ) / temp_output_2_0_g1 )).x;
				#else
				float staticSwitch131 = main_r_ref144;
				#endif
				float vert_uv1_u_ref140 = IN.ase_texcoord4.x;
				#ifdef USE_CUSTOM_ON
				float staticSwitch61 = vert_uv1_u_ref140;
				#else
				float staticSwitch61 = _Main_Ins;
				#endif
				float4 vert_color_ref160 = IN.ase_color;
				
				float vert_alpha_ref161 = IN.ase_color.a;
				float2 appendResult53 = (float2(_Diss_Tex_UPanner , _Diss_Tex_VPanner));
				float2 uv_Diss_Texture = IN.ase_texcoord3.xy * _Diss_Texture_ST.xy + _Diss_Texture_ST.zw;
				float2 panner54 = ( 1.0 * _Time.y * appendResult53 + uv_Diss_Texture);
				float vert_uv1_v_ref141 = IN.ase_texcoord4.y;
				#ifdef USE_CUSTOM_ON
				float staticSwitch62 = vert_uv1_v_ref141;
				#else
				float staticSwitch62 = _Dissolve;
				#endif
				float2 texCoord8 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float uv_v148 = texCoord8.y;
				#ifdef _MASK_1X_ON
				float staticSwitch81 = saturate( ( 1.0 - uv_v148 ) );
				#else
				float staticSwitch81 = uv_v148;
				#endif
				#ifdef _MASK_MIRROR_ON
				float staticSwitch82 = ( saturate( ( uv_v148 * saturate( ( 1.0 - uv_v148 ) ) ) ) * 4.0 );
				#else
				float staticSwitch82 = staticSwitch81;
				#endif
				float mask_pow_ref151 = _Mask_Pow;
				float2 texCoord83 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USE_MASKTEX_ON
				float staticSwitch89 = saturate( pow( tex2D( _Mask_Texture, texCoord83 ).r , mask_pow_ref151 ) );
				#else
				float staticSwitch89 = saturate( pow( staticSwitch82 , mask_pow_ref151 ) );
				#endif
				float mask_ref153 = staticSwitch89;
				#ifdef _USE_ADDMULITYMASK_ON
				float staticSwitch109 = ( ( main_r_ref144 + mask_ref153 ) * mask_ref153 );
				#else
				float staticSwitch109 = ( main_r_ref144 * mask_ref153 );
				#endif
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth69 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth69 = abs( ( screenDepth69 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Fade_Distance ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( ( saturate( ( saturate( pow( tex2D( _Sub_Texture, panner92 ).r , _SubTex_Pow ) ) * _SubTex_Ins ) ) * _SubTex_Color ) + ( _TintColor * ( saturate( pow( staticSwitch131 , _Main_Pow ) ) * staticSwitch61 ) ) ) * vert_color_ref160 ).rgb;
				float Alpha = ( vert_alpha_ref161 * ( saturate( ( _Opacity * ( saturate( ( tex2D( _Diss_Texture, panner54 ).r + staticSwitch62 ) ) * staticSwitch109 ) ) ) * saturate( distanceDepth69 ) ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

			Cull Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _USE_VERTEX_ON
			#pragma shader_feature_local USE_CUSTOM_ON
			#pragma shader_feature_local _USE_ADDMULITYMASK_ON
			#pragma shader_feature_local _USE_MASKTEX_ON
			#pragma shader_feature_local _MASK_MIRROR_ON
			#pragma shader_feature_local _MASK_1X_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Noise_Texture_ST;
			float4 _Diss_Texture_ST;
			float4 _TintColor;
			float4 _SubTex_Color;
			float4 _Main_Texture_ST;
			float4 _Sub_Texture_ST;
			float _Noise_Tex_VPanner;
			float _Noise_Str;
			float _Ceil;
			float _Main_Pow;
			float _Main_Ins;
			float _Opacity;
			float _Diss_Tex_UPanner;
			float _Diss_Tex_VPanner;
			float _Dissolve;
			float _Noise_Tex_UPanner;
			float _Src;
			float _Main_VPanner;
			float _Main_UPanner;
			float _SubTex_Ins;
			float _SubTex_Pow;
			float _SubTex_VPanner;
			float _SubTex_UPanner;
			float _vertex_str;
			float _vertex_pow;
			float _vertex_vpanner;
			float _vertex_upanner;
			float _CullMode;
			float _Dst;
			float _Mask_Pow;
			float _Fade_Distance;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Vertex_texture;
			sampler2D _Diss_Texture;
			sampler2D _Main_Texture;
			sampler2D _Noise_Texture;
			sampler2D _Mask_Texture;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult171 = (float2(_vertex_upanner , _vertex_vpanner));
				float2 texCoord167 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner168 = ( 1.0 * _Time.y * appendResult171 + texCoord167);
				#ifdef _USE_VERTEX_ON
				float3 staticSwitch180 = ( v.ase_normal * ( saturate( pow( tex2Dlod( _Vertex_texture, float4( panner168, 0, 0.0) ).r , _vertex_pow ) ) * _vertex_str ) );
				#else
				float3 staticSwitch180 = float3( 0,0,0 );
				#endif
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch180;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float vert_alpha_ref161 = IN.ase_color.a;
				float2 appendResult53 = (float2(_Diss_Tex_UPanner , _Diss_Tex_VPanner));
				float2 uv_Diss_Texture = IN.ase_texcoord.xy * _Diss_Texture_ST.xy + _Diss_Texture_ST.zw;
				float2 panner54 = ( 1.0 * _Time.y * appendResult53 + uv_Diss_Texture);
				float vert_uv1_v_ref141 = IN.ase_texcoord1.y;
				#ifdef USE_CUSTOM_ON
				float staticSwitch62 = vert_uv1_v_ref141;
				#else
				float staticSwitch62 = _Dissolve;
				#endif
				float2 appendResult7 = (float2(_Main_UPanner , _Main_VPanner));
				float2 uv_Noise_Texture = IN.ase_texcoord.xy * _Noise_Texture_ST.xy + _Noise_Texture_ST.zw;
				float2 appendResult32 = (float2(_Noise_Tex_UPanner , _Noise_Tex_VPanner));
				float2 uv_Main_Texture = IN.ase_texcoord.xy * _Main_Texture_ST.xy + _Main_Texture_ST.zw;
				float2 temp_output_28_0 = ( ( (UnpackNormalScale( tex2D( _Noise_Texture, (uv_Noise_Texture*1.0 + ( appendResult32 * _TimeParameters.x )) ), 1.0f )).xy * _Noise_Str ) + uv_Main_Texture );
				float2 panner130 = ( 1.0 * _Time.y * appendResult7 + temp_output_28_0);
				float main_r_ref144 = tex2D( _Main_Texture, panner130 ).r;
				float2 texCoord8 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float uv_v148 = texCoord8.y;
				#ifdef _MASK_1X_ON
				float staticSwitch81 = saturate( ( 1.0 - uv_v148 ) );
				#else
				float staticSwitch81 = uv_v148;
				#endif
				#ifdef _MASK_MIRROR_ON
				float staticSwitch82 = ( saturate( ( uv_v148 * saturate( ( 1.0 - uv_v148 ) ) ) ) * 4.0 );
				#else
				float staticSwitch82 = staticSwitch81;
				#endif
				float mask_pow_ref151 = _Mask_Pow;
				float2 texCoord83 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USE_MASKTEX_ON
				float staticSwitch89 = saturate( pow( tex2D( _Mask_Texture, texCoord83 ).r , mask_pow_ref151 ) );
				#else
				float staticSwitch89 = saturate( pow( staticSwitch82 , mask_pow_ref151 ) );
				#endif
				float mask_ref153 = staticSwitch89;
				#ifdef _USE_ADDMULITYMASK_ON
				float staticSwitch109 = ( ( main_r_ref144 + mask_ref153 ) * mask_ref153 );
				#else
				float staticSwitch109 = ( main_r_ref144 * mask_ref153 );
				#endif
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth69 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth69 = abs( ( screenDepth69 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Fade_Distance ) );
				

				surfaceDescription.Alpha = ( vert_alpha_ref161 * ( saturate( ( _Opacity * ( saturate( ( tex2D( _Diss_Texture, panner54 ).r + staticSwitch62 ) ) * staticSwitch109 ) ) ) * saturate( distanceDepth69 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _USE_VERTEX_ON
			#pragma shader_feature_local USE_CUSTOM_ON
			#pragma shader_feature_local _USE_ADDMULITYMASK_ON
			#pragma shader_feature_local _USE_MASKTEX_ON
			#pragma shader_feature_local _MASK_MIRROR_ON
			#pragma shader_feature_local _MASK_1X_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Noise_Texture_ST;
			float4 _Diss_Texture_ST;
			float4 _TintColor;
			float4 _SubTex_Color;
			float4 _Main_Texture_ST;
			float4 _Sub_Texture_ST;
			float _Noise_Tex_VPanner;
			float _Noise_Str;
			float _Ceil;
			float _Main_Pow;
			float _Main_Ins;
			float _Opacity;
			float _Diss_Tex_UPanner;
			float _Diss_Tex_VPanner;
			float _Dissolve;
			float _Noise_Tex_UPanner;
			float _Src;
			float _Main_VPanner;
			float _Main_UPanner;
			float _SubTex_Ins;
			float _SubTex_Pow;
			float _SubTex_VPanner;
			float _SubTex_UPanner;
			float _vertex_str;
			float _vertex_pow;
			float _vertex_vpanner;
			float _vertex_upanner;
			float _CullMode;
			float _Dst;
			float _Mask_Pow;
			float _Fade_Distance;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Vertex_texture;
			sampler2D _Diss_Texture;
			sampler2D _Main_Texture;
			sampler2D _Noise_Texture;
			sampler2D _Mask_Texture;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			float4 _SelectionID;


			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult171 = (float2(_vertex_upanner , _vertex_vpanner));
				float2 texCoord167 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner168 = ( 1.0 * _Time.y * appendResult171 + texCoord167);
				#ifdef _USE_VERTEX_ON
				float3 staticSwitch180 = ( v.ase_normal * ( saturate( pow( tex2Dlod( _Vertex_texture, float4( panner168, 0, 0.0) ).r , _vertex_pow ) ) * _vertex_str ) );
				#else
				float3 staticSwitch180 = float3( 0,0,0 );
				#endif
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = staticSwitch180;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float vert_alpha_ref161 = IN.ase_color.a;
				float2 appendResult53 = (float2(_Diss_Tex_UPanner , _Diss_Tex_VPanner));
				float2 uv_Diss_Texture = IN.ase_texcoord.xy * _Diss_Texture_ST.xy + _Diss_Texture_ST.zw;
				float2 panner54 = ( 1.0 * _Time.y * appendResult53 + uv_Diss_Texture);
				float vert_uv1_v_ref141 = IN.ase_texcoord1.y;
				#ifdef USE_CUSTOM_ON
				float staticSwitch62 = vert_uv1_v_ref141;
				#else
				float staticSwitch62 = _Dissolve;
				#endif
				float2 appendResult7 = (float2(_Main_UPanner , _Main_VPanner));
				float2 uv_Noise_Texture = IN.ase_texcoord.xy * _Noise_Texture_ST.xy + _Noise_Texture_ST.zw;
				float2 appendResult32 = (float2(_Noise_Tex_UPanner , _Noise_Tex_VPanner));
				float2 uv_Main_Texture = IN.ase_texcoord.xy * _Main_Texture_ST.xy + _Main_Texture_ST.zw;
				float2 temp_output_28_0 = ( ( (UnpackNormalScale( tex2D( _Noise_Texture, (uv_Noise_Texture*1.0 + ( appendResult32 * _TimeParameters.x )) ), 1.0f )).xy * _Noise_Str ) + uv_Main_Texture );
				float2 panner130 = ( 1.0 * _Time.y * appendResult7 + temp_output_28_0);
				float main_r_ref144 = tex2D( _Main_Texture, panner130 ).r;
				float2 texCoord8 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float uv_v148 = texCoord8.y;
				#ifdef _MASK_1X_ON
				float staticSwitch81 = saturate( ( 1.0 - uv_v148 ) );
				#else
				float staticSwitch81 = uv_v148;
				#endif
				#ifdef _MASK_MIRROR_ON
				float staticSwitch82 = ( saturate( ( uv_v148 * saturate( ( 1.0 - uv_v148 ) ) ) ) * 4.0 );
				#else
				float staticSwitch82 = staticSwitch81;
				#endif
				float mask_pow_ref151 = _Mask_Pow;
				float2 texCoord83 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USE_MASKTEX_ON
				float staticSwitch89 = saturate( pow( tex2D( _Mask_Texture, texCoord83 ).r , mask_pow_ref151 ) );
				#else
				float staticSwitch89 = saturate( pow( staticSwitch82 , mask_pow_ref151 ) );
				#endif
				float mask_ref153 = staticSwitch89;
				#ifdef _USE_ADDMULITYMASK_ON
				float staticSwitch109 = ( ( main_r_ref144 + mask_ref153 ) * mask_ref153 );
				#else
				float staticSwitch109 = ( main_r_ref144 * mask_ref153 );
				#endif
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth69 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth69 = abs( ( screenDepth69 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Fade_Distance ) );
				

				surfaceDescription.Alpha = ( vert_alpha_ref161 * ( saturate( ( _Opacity * ( saturate( ( tex2D( _Diss_Texture, panner54 ).r + staticSwitch62 ) ) * staticSwitch109 ) ) ) * saturate( distanceDepth69 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _USE_VERTEX_ON
			#pragma shader_feature_local USE_CUSTOM_ON
			#pragma shader_feature_local _USE_ADDMULITYMASK_ON
			#pragma shader_feature_local _USE_MASKTEX_ON
			#pragma shader_feature_local _MASK_MIRROR_ON
			#pragma shader_feature_local _MASK_1X_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Noise_Texture_ST;
			float4 _Diss_Texture_ST;
			float4 _TintColor;
			float4 _SubTex_Color;
			float4 _Main_Texture_ST;
			float4 _Sub_Texture_ST;
			float _Noise_Tex_VPanner;
			float _Noise_Str;
			float _Ceil;
			float _Main_Pow;
			float _Main_Ins;
			float _Opacity;
			float _Diss_Tex_UPanner;
			float _Diss_Tex_VPanner;
			float _Dissolve;
			float _Noise_Tex_UPanner;
			float _Src;
			float _Main_VPanner;
			float _Main_UPanner;
			float _SubTex_Ins;
			float _SubTex_Pow;
			float _SubTex_VPanner;
			float _SubTex_UPanner;
			float _vertex_str;
			float _vertex_pow;
			float _vertex_vpanner;
			float _vertex_upanner;
			float _CullMode;
			float _Dst;
			float _Mask_Pow;
			float _Fade_Distance;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Vertex_texture;
			sampler2D _Diss_Texture;
			sampler2D _Main_Texture;
			sampler2D _Noise_Texture;
			sampler2D _Mask_Texture;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult171 = (float2(_vertex_upanner , _vertex_vpanner));
				float2 texCoord167 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner168 = ( 1.0 * _Time.y * appendResult171 + texCoord167);
				#ifdef _USE_VERTEX_ON
				float3 staticSwitch180 = ( v.ase_normal * ( saturate( pow( tex2Dlod( _Vertex_texture, float4( panner168, 0, 0.0) ).r , _vertex_pow ) ) * _vertex_str ) );
				#else
				float3 staticSwitch180 = float3( 0,0,0 );
				#endif
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch180;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag( VertexOutput IN
				, out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
			#endif
				 )
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float vert_alpha_ref161 = IN.ase_color.a;
				float2 appendResult53 = (float2(_Diss_Tex_UPanner , _Diss_Tex_VPanner));
				float2 uv_Diss_Texture = IN.ase_texcoord1.xy * _Diss_Texture_ST.xy + _Diss_Texture_ST.zw;
				float2 panner54 = ( 1.0 * _Time.y * appendResult53 + uv_Diss_Texture);
				float vert_uv1_v_ref141 = IN.ase_texcoord2.y;
				#ifdef USE_CUSTOM_ON
				float staticSwitch62 = vert_uv1_v_ref141;
				#else
				float staticSwitch62 = _Dissolve;
				#endif
				float2 appendResult7 = (float2(_Main_UPanner , _Main_VPanner));
				float2 uv_Noise_Texture = IN.ase_texcoord1.xy * _Noise_Texture_ST.xy + _Noise_Texture_ST.zw;
				float2 appendResult32 = (float2(_Noise_Tex_UPanner , _Noise_Tex_VPanner));
				float2 uv_Main_Texture = IN.ase_texcoord1.xy * _Main_Texture_ST.xy + _Main_Texture_ST.zw;
				float2 temp_output_28_0 = ( ( (UnpackNormalScale( tex2D( _Noise_Texture, (uv_Noise_Texture*1.0 + ( appendResult32 * _TimeParameters.x )) ), 1.0f )).xy * _Noise_Str ) + uv_Main_Texture );
				float2 panner130 = ( 1.0 * _Time.y * appendResult7 + temp_output_28_0);
				float main_r_ref144 = tex2D( _Main_Texture, panner130 ).r;
				float2 texCoord8 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float uv_v148 = texCoord8.y;
				#ifdef _MASK_1X_ON
				float staticSwitch81 = saturate( ( 1.0 - uv_v148 ) );
				#else
				float staticSwitch81 = uv_v148;
				#endif
				#ifdef _MASK_MIRROR_ON
				float staticSwitch82 = ( saturate( ( uv_v148 * saturate( ( 1.0 - uv_v148 ) ) ) ) * 4.0 );
				#else
				float staticSwitch82 = staticSwitch81;
				#endif
				float mask_pow_ref151 = _Mask_Pow;
				float2 texCoord83 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USE_MASKTEX_ON
				float staticSwitch89 = saturate( pow( tex2D( _Mask_Texture, texCoord83 ).r , mask_pow_ref151 ) );
				#else
				float staticSwitch89 = saturate( pow( staticSwitch82 , mask_pow_ref151 ) );
				#endif
				float mask_ref153 = staticSwitch89;
				#ifdef _USE_ADDMULITYMASK_ON
				float staticSwitch109 = ( ( main_r_ref144 + mask_ref153 ) * mask_ref153 );
				#else
				float staticSwitch109 = ( main_r_ref144 * mask_ref153 );
				#endif
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth69 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth69 = abs( ( screenDepth69 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Fade_Distance ) );
				

				surfaceDescription.Alpha = ( vert_alpha_ref161 * ( saturate( ( _Opacity * ( saturate( ( tex2D( _Diss_Texture, panner54 ).r + staticSwitch62 ) ) * staticSwitch109 ) ) ) * saturate( distanceDepth69 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float3 normalWS = normalize(IN.normalWS);
					float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					float3 normalWS = IN.normalWS;
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}

			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;164;-2486.049,60.87212;Inherit;False;467.1248;422.2737;;6;63;140;141;58;160;161;Vertex Data;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-3640.029,-798.2134;Inherit;False;1470;452;;12;26;27;25;24;123;124;127;126;30;33;34;32;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;15;-3822.011,795.829;Inherit;False;2183.075;973.5074;;24;153;87;86;151;85;84;83;152;89;13;12;81;82;11;45;149;10;137;9;79;138;150;148;8;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-1665.89,153.9512;Inherit;False;1341.009;451.5437;Dissolve;11;49;47;143;62;48;50;51;53;52;46;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;106;-1183.685,-966.4841;Inherit;False;1591.756;513.8267;SubTex;14;93;92;97;95;96;90;99;101;98;100;102;103;111;139;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;54;-1243.89,243.9514;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;90;-646.6897,-916.4841;Inherit;True;Property;_Sub_Texture;Sub_Texture;21;0;Create;True;0;0;0;False;0;False;-1;None;f03a7b6ea419e314e8c52b72b5a7f6cd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;107;-165.9924,380.5667;Inherit;False;552.7916;168.0119;DepthFade;3;72;69;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;70;241.7989,430.567;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;1556.308,-685.0661;Inherit;False;222;346;Enum;3;73;74;75;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;112;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;114;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;115;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;116;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;117;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;2;5;True;_Src;10;True;_Dst;3;1;True;_Src;10;True;_Dst;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;119;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;120;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;1058.258,-529.7874;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.SamplerNode;46;-1042.989,256.0834;Inherit;True;Property;_Diss_Texture;Diss_Texture;15;0;Create;True;0;0;0;False;0;False;-1;None;145143eb93006454baed654b5669d0c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;32;-3392.029,-579.213;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-3622.029,-585.213;Inherit;False;Property;_Noise_Tex_UPanner;Noise_Tex_UPanner;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3620.029,-517.213;Inherit;False;Property;_Noise_Tex_VPanner;Noise_Tex_VPanner;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-3474.029,-702.2132;Inherit;False;0;24;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;126;-3501.933,-439.3032;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-3619.933,-442.3033;Inherit;False;Constant;_Float0;Float 0;34;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-3226.818,-463.7649;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;123;-3042.818,-695.765;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;24;-2867.029,-724.213;Inherit;True;Property;_Noise_Texture;Noise_Texture;11;0;Create;True;0;0;0;False;0;False;-1;None;0c9e585b001cd8048afcd07b5676b774;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;25;-2591.028,-723.213;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2590.028,-653.213;Inherit;False;Property;_Noise_Str;Noise_Str;12;0;Create;True;0;0;0;False;0;False;0.06793601;0.1438;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-2313.028,-719.213;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-1512.89,238.9512;Inherit;False;0;46;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;53;-1430.89,358.9514;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1645.89,353.9514;Inherit;False;Property;_Diss_Tex_UPanner;Diss_Tex_UPanner;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1643.89,427.9514;Inherit;False;Property;_Diss_Tex_VPanner;Diss_Tex_VPanner;20;0;Create;True;0;0;0;False;0;False;0;-0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1232.746,442.3705;Inherit;False;Property;_Dissolve;Dissolve;16;0;Create;True;0;0;0;False;0;False;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;62;-962.2659,441.8891;Inherit;False;Property;Use_Custom;Use_Custom;17;0;Create;False;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-1153.463,511.4221;Inherit;False;141;vert_uv1_v_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-701.1985,284.9438;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;49;-595.9221,285.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-3779.511,911.6397;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-3577.135,954.1572;Inherit;False;uv_v;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-3553.566,1171.691;Inherit;False;148;uv_v;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;138;-3214.649,1268.532;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;79;-3343.843,1269.01;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;9;-3335.313,1451.711;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;137;-3202.742,1451.668;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3056.313,1346.711;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-3530.637,1338.828;Inherit;False;148;uv_v;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-2940.259,1349.171;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-2820.513,1351.711;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;82;-2657.742,1168.809;Inherit;False;Property;_Mask_Mirror;Mask_Mirror;31;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;81;-3055.242,1174.309;Inherit;False;Property;_Mask_1x;Mask_-1x;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;12;-2422.397,1174.227;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;13;-2291.833,1174.28;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;89;-2112.58,1169.74;Inherit;False;Property;_Use_MaskTex;Use_MaskTex;28;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-2625.133,1259.927;Inherit;False;151;mask_pow_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;83;-2948.931,1509.183;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;84;-2752.475,1481.315;Inherit;True;Property;_Mask_Texture;Mask_Texture;27;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;-2908.591,1664.94;Inherit;False;Property;_Mask_Pow;Mask_Pow;30;0;Create;True;0;0;0;False;0;False;5.346326;5.346326;1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;151;-2656.133,1665.927;Inherit;False;mask_pow_ref;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;86;-2415.365,1510.358;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;87;-2283.138,1511.279;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;-1906.357,1169.49;Inherit;False;mask_ref;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;109;-531.1923,625.1513;Inherit;False;Property;_Use_AddMulityMask;Use_AddMulityMask;32;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-722.2601,782.2266;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;-867.4424,779.9772;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-1059.824,775.162;Inherit;False;144;main_r_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-1054.457,842.6542;Inherit;False;153;mask_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-1056.07,911.4286;Inherit;False;153;mask_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;157;-775.0414,911.9404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-876.925,632.9444;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;-1056.142,702.1734;Inherit;False;153;mask_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-1060.041,628.8394;Inherit;False;144;main_r_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-167.4955,280.5073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1852.191,-93.89805;Inherit;False;Property;_Main_VPanner;Main_VPanner;6;0;Create;True;0;0;0;False;0;False;0.39;-1.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;67;-1972.004,-267.0655;Inherit;False;Property;Use_Custom;Use_Custom;19;0;Create;False;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;65;-1714.272,-286.353;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;66;-2158.275,-146.6156;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;68;-2156.475,-266.6535;Inherit;False;Property;_main_scale;main_scale;19;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1885.143,-358.5186;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-2361.929,-340.9175;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-1856.615,-164.7427;Inherit;False;Property;_Main_UPanner;Main_UPanner;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-1658.14,-158.7427;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;130;-1484.213,-354.6597;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1325.095,-384.5952;Inherit;True;Property;_Main_Texture;Main_Texture;3;0;Create;True;0;0;0;False;0;False;-1;07454a717364c364b9bc4becd33778da;145143eb93006454baed654b5669d0c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-1052.14,-360.7257;Inherit;False;main_r_ref;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1025.14,-292.7257;Inherit;False;144;main_r_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-990.5313,-222.1104;Inherit;False;Property;_Ceil;Ceil;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;158;-843.8257,-288.2699;Inherit;False;F_Toon;-1;;1;611313da66c9ce042a4ae9bf3e5290ab;0;2;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;159;-680.8257,-294.2699;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;131;-487.3854,-363.1104;Inherit;False;Property;_Use_Ceil;Use_Ceil;33;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-677.1745,-225.6922;Inherit;False;Property;_Main_Pow;Main_Pow;8;0;Create;True;0;0;0;False;0;False;1;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;16;-272.5183,-357.4535;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;61;-331.1506,-119.8923;Inherit;False;Property;Use_Custom;Use_Custom;16;0;Create;False;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-620.7347,-119.791;Inherit;False;Property;_Main_Ins;Main_Ins;7;0;Create;True;0;0;0;False;0;False;1;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-538.385,-53.96419;Inherit;False;140;vert_uv1_u_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;136;-141.0164,-356.1233;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;37.55221,-142.201;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;38.90454,-316.5952;Inherit;False;Property;_TintColor;Tint Color;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1.971694,25.66678,59.71412,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;313.7679,-163.2334;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;97;-972.9296,-764.6571;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1194.929,-701.6571;Inherit;False;Property;_SubTex_VPanner;SubTex_VPanner;26;0;Create;True;0;0;0;False;0;False;0;-0.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-1196.929,-770.6571;Inherit;False;Property;_SubTex_UPanner;SubTex_UPanner;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-1196.685,-890.0051;Inherit;False;0;90;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;92;-803.6852,-885.0051;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-622.9296,-734.6571;Inherit;False;Property;_SubTex_Pow;SubTex_Pow;24;0;Create;True;0;0;0;False;0;False;0;5.33;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-623.6653,-663.9341;Inherit;False;Property;_SubTex_Ins;SubTex_Ins;23;0;Create;True;0;0;0;False;0;False;0;4.31;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;98;-300.9296,-887.657;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;111;-169.1905,-887.7561;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;5.721565,-689.0652;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;139;121.0776,-691.2062;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;103;6.222076,-597.941;Inherit;False;Property;_SubTex_Color;SubTex_Color;22;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;87.97024,89.45408,61.18321,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;270.3081,-690.9412;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;479.0149,-690.2177;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;58;-2403.615,276.1459;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-2261.529,271.4607;Inherit;False;vert_color_ref;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;-2260.529,366.4607;Inherit;False;vert_alpha_ref;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-306.9396,208.5577;Inherit;False;Property;_Opacity;Opacity;9;0;Create;True;0;0;0;False;0;False;1;6.79;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-2.070854,255.9248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;22;116.9171,256.6121;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;422.7404,256.8636;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;69;18.95576,429.5789;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-138.9923,448.8524;Inherit;False;Property;_Fade_Distance;Fade_Distance;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;362.1547,180.6084;Inherit;False;161;vert_alpha_ref;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;567.8498,186.5848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;482.5727,-601.8499;Inherit;False;160;vert_color_ref;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;695.9782,-688.5811;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;74;1610.308,-548.0662;Inherit;False;Property;_Src;Src;1;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;1610.308,-455.0662;Inherit;False;Property;_Dst;Dst;2;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;1606.308,-635.0662;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;113;1329.353,-687.4009;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;1_fx/shokewave;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_CullMode;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;True;True;2;5;True;_Src;10;True;_Dst;2;5;True;_Src;10;True;_Dst;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;0;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;1;638387539112172886;  Blend;0;0;Two Sided;1;0;Forward Only;0;0;Cast Shadows;0;638387539142243526;  Use Shadow Threshold;0;0;Receive Shadows;0;638387539148933291;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;False;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.WireNode;165;737.7969,-417.7505;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;171;-234.9946,1184.303;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-434.9946,1180.303;Inherit;False;Property;_vertex_upanner;vertex_upanner;36;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-433.9946,1247.303;Inherit;False;Property;_vertex_vpanner;vertex_vpanner;37;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;167;-432.9946,1067.303;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;168;-90.99463,1067.303;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;166;70.70398,1039.224;Inherit;True;Property;_Vertex_texture;Vertex_texture;35;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;172;400.0054,1068.303;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;174;528.0054,1068.303;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;655.0054,1068.303;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;208.0054,1222.303;Inherit;False;Property;_vertex_pow;vertex_pow;38;0;Create;True;0;0;0;False;0;False;3.71;3.71;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;217.0054,1293.303;Inherit;False;Property;_vertex_str;vertex_str;39;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;177;562.0054,1278.303;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;178;616.8168,929.9827;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;824.702,1046.755;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;180;985.0681,927.9871;Inherit;False;Property;_Use_vertex;Use_vertex;40;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;63;-2436.049,110.8721;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;141;-2242.924,197.1245;Inherit;False;vert_uv1_v_ref;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-2244.133,129.707;Inherit;False;vert_uv1_u_ref;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;64;-2333.961,-169.6613;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;54;0;52;0
WireConnection;54;2;53;0
WireConnection;90;1;92;0
WireConnection;70;0;69;0
WireConnection;46;1;54;0
WireConnection;32;0;34;0
WireConnection;32;1;33;0
WireConnection;126;0;127;0
WireConnection;124;0;32;0
WireConnection;124;1;126;0
WireConnection;123;0;30;0
WireConnection;123;2;124;0
WireConnection;24;1;123;0
WireConnection;25;0;24;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;53;0;51;0
WireConnection;53;1;50;0
WireConnection;62;1;48;0
WireConnection;62;0;143;0
WireConnection;47;0;46;1
WireConnection;47;1;62;0
WireConnection;49;0;47;0
WireConnection;148;0;8;2
WireConnection;138;0;79;0
WireConnection;79;0;150;0
WireConnection;9;0;149;0
WireConnection;137;0;9;0
WireConnection;10;0;149;0
WireConnection;10;1;137;0
WireConnection;45;0;10;0
WireConnection;11;0;45;0
WireConnection;82;1;81;0
WireConnection;82;0;11;0
WireConnection;81;1;150;0
WireConnection;81;0;138;0
WireConnection;12;0;82;0
WireConnection;12;1;152;0
WireConnection;13;0;12;0
WireConnection;89;1;13;0
WireConnection;89;0;87;0
WireConnection;84;1;83;0
WireConnection;151;0;85;0
WireConnection;86;0;84;1
WireConnection;86;1;151;0
WireConnection;87;0;86;0
WireConnection;153;0;89;0
WireConnection;109;1;14;0
WireConnection;109;0;110;0
WireConnection;110;0;108;0
WireConnection;110;1;157;0
WireConnection;108;0;147;0
WireConnection;108;1;155;0
WireConnection;157;0;154;0
WireConnection;14;0;146;0
WireConnection;14;1;156;0
WireConnection;56;0;49;0
WireConnection;56;1;109;0
WireConnection;67;1;68;0
WireConnection;67;0;66;0
WireConnection;65;0;28;0
WireConnection;65;1;67;0
WireConnection;66;0;64;1
WireConnection;66;1;64;2
WireConnection;28;0;26;0
WireConnection;28;1;4;0
WireConnection;7;0;5;0
WireConnection;7;1;6;0
WireConnection;130;0;28;0
WireConnection;130;2;7;0
WireConnection;1;1;130;0
WireConnection;144;0;1;1
WireConnection;158;1;145;0
WireConnection;158;2;132;0
WireConnection;159;0;158;0
WireConnection;131;1;144;0
WireConnection;131;0;159;0
WireConnection;16;0;131;0
WireConnection;16;1;18;0
WireConnection;61;1;19;0
WireConnection;61;0;142;0
WireConnection;136;0;16;0
WireConnection;17;0;136;0
WireConnection;17;1;61;0
WireConnection;23;0;2;0
WireConnection;23;1;17;0
WireConnection;97;0;95;0
WireConnection;97;1;96;0
WireConnection;92;0;93;0
WireConnection;92;2;97;0
WireConnection;98;0;90;1
WireConnection;98;1;99;0
WireConnection;111;0;98;0
WireConnection;100;0;111;0
WireConnection;100;1;101;0
WireConnection;139;0;100;0
WireConnection;102;0;139;0
WireConnection;102;1;103;0
WireConnection;105;0;102;0
WireConnection;105;1;23;0
WireConnection;160;0;58;0
WireConnection;161;0;58;4
WireConnection;20;0;21;0
WireConnection;20;1;56;0
WireConnection;22;0;20;0
WireConnection;71;0;22;0
WireConnection;71;1;70;0
WireConnection;69;0;72;0
WireConnection;60;0;163;0
WireConnection;60;1;71;0
WireConnection;59;0;105;0
WireConnection;59;1;162;0
WireConnection;113;2;59;0
WireConnection;113;3;165;0
WireConnection;113;5;180;0
WireConnection;165;0;60;0
WireConnection;171;0;169;0
WireConnection;171;1;170;0
WireConnection;168;0;167;0
WireConnection;168;2;171;0
WireConnection;166;1;168;0
WireConnection;172;0;166;1
WireConnection;172;1;173;0
WireConnection;174;0;172;0
WireConnection;175;0;174;0
WireConnection;175;1;177;0
WireConnection;177;0;176;0
WireConnection;179;0;178;0
WireConnection;179;1;175;0
WireConnection;180;0;179;0
WireConnection;141;0;63;2
WireConnection;140;0;63;1
ASEEND*/
//CHKSM=F4D4EBC26A3D633294A8B9F2D955493DAB119D00