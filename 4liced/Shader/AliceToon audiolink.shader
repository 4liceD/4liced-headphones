// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "4liceD/AliceToon audiolink"
{
	Properties
	{
		[Header(Basecolor)]_Color("Color", Color) = (1,1,1,0)
		_MainTex("Basecolor", 2D) = "white" {}
		_Packed("Packed", 2D) = "white" {}
		[HDR]_RimColor("Rim Color", Color) = (0,1,0.8745098,0)
		_RimPower("Rim Power", Range( 0 , 10)) = 0
		_RimOffset("Rim Offset", Float) = 0.24
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_Emission("Emission Map", 2D) = "white" {}
		_AudiolinkChannel("AudiolinkChannel", Range( 0 , 3)) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Culling Mode", Int) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull [_Cull]
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform int _Cull;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _NormalScale;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float4 _EmissionColor;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float _AudiolinkChannel;
		uniform sampler2D _Packed;
		uniform float4 _Packed_ST;


		inline float AudioLinkData3_g1( int Band, int Delay )
		{
			return AudioLinkData( ALPASS_AUDIOLINK + uint2( Delay, Band ) ).rrrr;
		}


		float IfAudioLinkv2Exists1_g2(  )
		{
			int w = 0; 
			int h; 
			int res = 0;
			#ifndef SHADER_TARGET_SURFACE_ANALYSIS
			_AudioTexture.GetDimensions(w, h); 
			#endif
			if (w == 128) res = 1;
			return res;
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			SurfaceOutputStandard s20 = (SurfaceOutputStandard ) 0;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			UnityGI gi29 = gi;
			float3 diffNorm29 = ase_normWorldNormal;
			gi29 = UnityGI_Base( data, 1, diffNorm29 );
			float3 indirectDiffuse29 = gi29.indirect.diffuse + diffNorm29 * 0.0001;
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 tex2DNode51 = UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale );
			float3 normal53 = normalize( (WorldNormalVector( i , tex2DNode51 )) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( normal53 , ase_worldlightDir );
			float normal_lightdir8 = dotResult3;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult6 = dot( ase_normWorldNormal , ase_worldViewDir );
			float normal_viewdir9 = dotResult6;
			s20.Albedo = ( ( ( tex2D( _MainTex, uv_MainTex ) * _Color ) * ( ase_lightColor * float4( ( indirectDiffuse29 + ase_lightAtten ) , 0.0 ) ) ) + ( saturate( ( ( saturate( (normal_lightdir8*0.5 + 0.5) ) * ase_lightAtten ) * pow( ( 1.0 - saturate( ( normal_viewdir9 + _RimOffset ) ) ) , _RimPower ) ) ) * ( _RimColor * ase_lightColor ) ) ).rgb;
			s20.Normal = normalize( WorldNormalVector( i , tex2DNode51 ) );
			float2 uv_Emission = i.uv_texcoord * _Emission_ST.xy + _Emission_ST.zw;
			float4 temp_output_76_0 = ( _EmissionColor * tex2D( _Emission, uv_Emission ) );
			int Band3_g1 = (int)_AudiolinkChannel;
			int Delay3_g1 = 0;
			float localAudioLinkData3_g1 = AudioLinkData3_g1( Band3_g1 , Delay3_g1 );
			float localIfAudioLinkv2Exists1_g2 = IfAudioLinkv2Exists1_g2();
			float temp_output_80_0 = localIfAudioLinkv2Exists1_g2;
			s20.Emission = ( ( temp_output_76_0 * localAudioLinkData3_g1 * temp_output_80_0 ) + ( temp_output_76_0 * ( 1.0 - temp_output_80_0 ) ) ).rgb;
			float2 uv_Packed = i.uv_texcoord * _Packed_ST.xy + _Packed_ST.zw;
			float4 tex2DNode11 = tex2D( _Packed, uv_Packed );
			s20.Metallic = tex2DNode11.r;
			s20.Smoothness = ( 1.0 - tex2DNode11.g );
			s20.Occlusion = tex2DNode11.b;

			data.light = gi.light;

			UnityGI gi20 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g20 = UnityGlossyEnvironmentSetup( s20.Smoothness, data.worldViewDir, s20.Normal, float3(0,0,0));
			gi20 = UnityGlobalIllumination( data, s20.Occlusion, s20.Normal, g20 );
			#endif

			float3 surfResult20 = LightingStandard ( s20, viewDir, gi20 ).rgb;
			surfResult20 += s20.Emission;

			#ifdef UNITY_PASS_FORWARDADD//20
			surfResult20 -= s20.Emission;
			#endif//20
			c.rgb = surfResult20;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d11 glcore gles gles3 vulkan 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "VRChat/Mobile/Toon Lit"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.SamplerNode;11;-1567.692,160.6909;Inherit;True;Property;_Packed;Packed;2;0;Create;True;0;0;0;False;0;False;-1;None;47416e2075830a24c867c9912552b293;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;17;-1143.349,263.6926;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2856.804,-717.9686;Inherit;False;723.599;290;Also know as Lambert Wrap or Half Lambert;3;24;23;22;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;-3799.757,-490.1266;Inherit;False;812;304;Comment;4;31;29;28;47;Attenuation and Ambient;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2806.804,-542.9685;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;24;-2308.206,-661.169;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;33;-3552.486,-1419.409;Inherit;False;1617.938;553.8222;;13;46;45;44;43;42;41;40;39;38;37;36;35;34;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-3472.486,-1147.409;Float;False;Property;_RimOffset;Rim Offset;5;0;Create;True;0;0;0;False;0;False;0.24;0.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-3264.486,-1259.409;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;-3104.486,-1259.409;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-3040.486,-1131.409;Float;False;Property;_RimPower;Rim Power;4;0;Create;True;0;0;0;False;0;False;0;2.22;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;39;-2736.486,-1259.409;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2496.487,-1291.409;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-2304.486,-1291.409;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-2112.486,-1291.409;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-2752.486,-1371.409;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;23;-2541.404,-667.9686;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;38;-2932.23,-1251.922;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;28;-3729.356,-306.1266;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;31;-3687.756,-442.1266;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.IndirectDiffuseLighting;29;-3470.78,-347.7523;Inherit;False;Tangent;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-3177.843,-356.1263;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2950.76,-482.0394;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;5;-4451.83,-1212.625;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;7;-4408.83,-968.6252;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;6;-4129.831,-1150.625;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-5387.396,-1614.072;Inherit;False;Property;_NormalScale;Normal Scale;7;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;52;-4779.397,-1662.072;Inherit;True;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;3;-3902.604,-1827.987;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;4;-4146.605,-1735.987;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;54;-4453.251,-1904.56;Inherit;False;53;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-626.2429,-520.1034;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;42;-2589.64,-1150.332;Float;False;Property;_RimColor;Rim Color;3;1;[HDR];Create;True;0;0;0;False;0;False;0,1,0.8745098,0;1,0.345426,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;43;-2484.947,-965.5626;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2331.542,-1151.155;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-3235.566,-676.604;Inherit;False;8;normal_lightdir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-3887.831,-1138.625;Float;False;normal_viewdir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-810.7881,-857.2271;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;15;-1140.087,-859.402;Inherit;False;Property;_Color;Color;0;1;[Header];Create;False;1;Basecolor;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-1149.379,-1142.912;Inherit;True;Property;_MainTex;Basecolor;1;0;Create;False;0;0;0;False;0;False;-1;None;c14bd42d412cef14986024cb979fac3b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;51;-5223.754,-1357.927;Inherit;True;Property;_Normal;Normal;6;0;Create;True;0;0;0;False;0;False;-1;None;f6d217b9bd05ca447b06cde70eed96e8;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-4495.962,-1664.104;Inherit;True;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-3821.682,-1365.221;Inherit;False;9;normal_viewdir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;20;-804.2272,186.5224;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-3708.602,-1851.987;Float;True;normal_lightdir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;75;-1302.851,-382.105;Inherit;False;Property;_EmissionColor;EmissionColor;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.9427508,1,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-1065.851,-151.105;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-591.6262,-118.4458;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;70;-1481.102,-192.2095;Inherit;True;Property;_Emission;Emission Map;9;0;Create;False;0;0;0;False;0;False;-1;None;ef172b5512168c744890d58433853f8d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;74;-29.5166,-552.3965;Inherit;False;Property;_Cull;Culling Mode;11;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-885.3572,3.91476;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-2867.856,-142.731;Inherit;True;53;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;77;-1484.824,22.79216;Inherit;False;4BandAmplitude;-1;;1;f5073bb9076c4e24481a28578c80bed5;0;2;2;INT;0;False;4;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-1855.489,43.74273;Inherit;False;Property;_AudiolinkChannel;AudiolinkChannel;10;0;Create;True;0;0;0;False;0;False;0;2;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-931.9007,431.046;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;80;-1311.89,419.6407;Inherit;False;IsAudioLink;-1;;2;e83fef6181013ba4bacf30a3d9a31d37;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;83;-1127.195,480.3836;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-745.8574,425.9066;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,-1;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;4liceD/AliceToon audiolink;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;5;d3d11;glcore;gles;gles3;vulkan;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;VRChat/Mobile/Toon Lit;-1;-1;-1;-1;0;False;0;0;True;_Cull;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;11;2
WireConnection;24;0;23;0
WireConnection;35;0;68;0
WireConnection;35;1;34;0
WireConnection;36;0;35;0
WireConnection;39;0;38;0
WireConnection;39;1;37;0
WireConnection;41;0;40;0
WireConnection;41;1;39;0
WireConnection;45;0;41;0
WireConnection;46;0;45;0
WireConnection;46;1;44;0
WireConnection;40;0;24;0
WireConnection;40;1;28;0
WireConnection;23;0;26;0
WireConnection;23;1;22;0
WireConnection;23;2;22;0
WireConnection;38;0;36;0
WireConnection;47;0;29;0
WireConnection;47;1;28;0
WireConnection;48;0;31;0
WireConnection;48;1;47;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;52;0;51;0
WireConnection;3;0;54;0
WireConnection;3;1;4;0
WireConnection;16;0;71;0
WireConnection;16;1;48;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;9;0;6;0
WireConnection;71;0;14;0
WireConnection;71;1;15;0
WireConnection;51;5;50;0
WireConnection;53;0;52;0
WireConnection;20;0;64;0
WireConnection;20;1;51;0
WireConnection;20;2;84;0
WireConnection;20;3;11;1
WireConnection;20;4;17;0
WireConnection;20;5;11;3
WireConnection;8;0;3;0
WireConnection;76;0;75;0
WireConnection;76;1;70;0
WireConnection;64;0;16;0
WireConnection;64;1;46;0
WireConnection;79;0;76;0
WireConnection;79;1;77;0
WireConnection;79;2;80;0
WireConnection;77;2;78;0
WireConnection;82;0;76;0
WireConnection;82;1;83;0
WireConnection;83;0;80;0
WireConnection;84;0;79;0
WireConnection;84;1;82;0
WireConnection;0;13;20;0
ASEEND*/
//CHKSM=6CA66F14093DC31CD46F3FAF30DDB334E44F105D