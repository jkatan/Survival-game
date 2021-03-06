﻿Shader "Star/Starwall" {
	Properties{
		_SkyColor("Sky Color (RGB)", Color) = (1,1,1,1)
		_StarColor("Star Color (RGB)", Color) = (1,1,1,1)
		_MainTex("Star texture (RGBA)", 2D) = "white" {}
	_Noise("Noise (RGBA)", 2D) = "white" {}
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "AlphaTest+150" }
		GrabPass{ "_GrabPass" }
		LOD 200

		CGPROGRAM

	#pragma exclude_renderers gles
	#pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade addshadow
	#pragma target 3.0

	uniform int _ObstacleLength = 0;
	uniform float4 _Obstacles[10];

	sampler2D _MainTex;
	sampler2D _Noise;

	struct Input {
		float2 uv_MainTex;
		float3 color : COLOR;
		float3 viewDir;
		float4 screenPos;
	};

	fixed4 _SkyColor;
	fixed4 _StarColor;

	// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
	// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
	// #pragma instancing_options assumeuniformscaling
	UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void vert(inout appdata_full v) {

		float3 worldPos = mul((float3x4)unity_ObjectToWorld, v.vertex);

		float distLimit = 2;// how far away do obstacles reach
		v.color.r = 0;

		for (int i = 0; i < _ObstacleLength; i++) {
			float distMulti = (distLimit - min(distLimit, distance(worldPos.xyz, _Obstacles[i].xyz))) / distLimit;//distance falloff
			float offset = -(sin(distMulti) - 0.5) / 2 * distMulti;
			v.vertex.xyz += v.normal * offset;
			v.color.r += offset;
		}
	}

	void surf(Input IN, inout SurfaceOutputStandard o) {

		float2 screenUV = (IN.screenPos.xy / IN.screenPos.w) * float2(_ScreenParams.x / _ScreenParams.y, 1) * 2;
		float2 offset = float2(_Time.x, _Time.x) / 2;
		half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
		rim = pow(rim, 5);

		float noise = tex2D(_Noise, screenUV + offset);
		noise += tex2D(_Noise, screenUV / 2 - offset);
		noise += tex2D(_Noise, screenUV / 4 + offset);
		noise = saturate(noise);

		fixed4 c = tex2D(_MainTex, screenUV - offset / 2) / 2;
		c += tex2D(_MainTex, screenUV * 2 + offset / 4) / 4;
		c += tex2D(_MainTex, screenUV * 4 - offset / 8) / 8;
		c = (1 - c) * _SkyColor + c * _StarColor;
		o.Albedo = c.rgb;

		o.Alpha = rim + noise;

		o.Emission = tex2D(_MainTex, screenUV / 2 + offset) * _StarColor * 2;
		o.Emission += _StarColor.rgb * rim + IN.color.r * _StarColor.zxy * 5;
	}
	ENDCG
	}
		FallBack "Transparent/Cutout/Diffuse"
}
