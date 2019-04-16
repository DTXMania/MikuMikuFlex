////////////////////////////////////////////////////////////////////////////////////////////////////
//
// �I�u�W�F�N�g�p�s�N�Z���V�F�[�_�[
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#include "MaterialTexture.hlsli"
#include "DefaultVS_OUTPUT.hlsli"
#include "GlobalParameters.hlsli"

SamplerState mySampler : register(s0);

float4 main(VS_OUTPUT IN) : SV_TARGET
{
	float4x4 WorldViewMatrix = mul(g_WorldMatrix, g_ViewMatrix);

    // ���ːF�v�Z
	
    float3 LightDirection = normalize(mul(g_Light1Direction, WorldViewMatrix)).xyz;
    float3 HalfVector = normalize(normalize(IN.Eye) - mul(float4(LightDirection, 0), WorldViewMatrix).xyz);
	float3 Specular = mul(pow(max(0.00001, dot(HalfVector, normalize(IN.Normal))), g_SpecularPower), g_SpecularColor.rgb);
    float4 Color = IN.Color;


	// �e�N�X�`���T���v�����O

    if (g_UseTexture)
    {
        Color *= g_Texture.Sample(mySampler, IN.Tex);
    }

	// �X�t�B�A�}�b�v�T���v�����O

    if (g_UseSphereMap)
    {
        if (g_IsAddSphere)
        {
            Color.rgb += g_SphereTexture.Sample(mySampler, IN.SpTex).rgb; // ���Z
        }
        else
        {
            Color.rgb *= g_SphereTexture.Sample(mySampler, IN.SpTex).rgb; // ��Z
        }
    }

	
	// �V�F�[�f�B���O

    //float LightNormal = dot(IN.Normal, -mul(float4(LightDirection, 0), matWV).xyz);
    float LightNormal = dot(IN.Normal, -LightDirection.xyz);
    float shading = saturate(LightNormal); // 0�`1 �Ɋۂ߂�


	// �g�D�[���e�N�X�`���T���v�����O
	
    if (g_UseToonTextureMap)
    {
        float3 MaterialToon = g_ToonTexture.Sample(mySampler, float2(0, shading)).rgb;
		Color.rgb *= 0.85f + MaterialToon * 0.15f;	// ���̂܂܂��ƔZ�䂢�̂Ŕ�������(0�`1 �� 0.95�`1)
    }
    else
    {
		shading = 0.95f + shading * 0.05f;	// ���̂܂܂��ƔZ�䂢�̂Ŕ�������(0�`1 �� 0.95�`1)
		float3 MaterialToon = 1.0f.xxx * shading;
        Color.rgb *= MaterialToon;
    }
    
    
    // �F�ɔ��ˌ������Z

    Color.rgb += Specular;

	
	// �F�Ɋ��������Z

	Color.rgb += mul(g_AmbientColor.rgb, 0.005);

    return Color;
}
