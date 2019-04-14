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
    // ���ːF�v�Z
	
    float3 LightDirection = normalize(mul(g_Light1Direction, g_WorldMatrix * g_ViewMatrix)).xyz;
    float3 HalfVector = normalize(normalize(IN.Eye) - mul(float4(LightDirection, 0), g_WorldMatrix * g_ViewMatrix).xyz);
    float3 Specular = pow(max(0.00001, dot(HalfVector, normalize(IN.Normal))), g_SpecularPower) * g_SpecularColor.rgb;
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

	shading = 0.85f + shading * 0.15f;	// ���̂܂܂��ƔZ�䂢�̂Ŕ�������(0�`1 �� 0.85�`1)


	// �g�D�[���e�N�X�`���T���v�����O
	
    if (g_UseToonTextureMap)
    {
        float3 MaterialToon = g_ToonTexture.Sample(mySampler, float2(0, shading)).rgb;
        Color.rgb *= MaterialToon;
    }
    else
    {
        float3 MaterialToon = 1.0f.xxx * shading;
        Color.rgb *= MaterialToon;
    }
    
    
    // �F�ɔ��ˌ������Z

    Color.rgb += Specular;

	
	// �F�Ɋ��������Z

	//Color.rgb += AmbientColor.rgb * 0.2;	//TODO MMD��Ambient�̌W�����킩���E�E�E
    Color.rgb += g_AmbientColor.rgb * 0.005;

    return Color;
}
