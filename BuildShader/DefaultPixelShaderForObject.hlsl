////////////////////////////////////////////////////////////////////////////////////////////////////
//
// �I�u�W�F�N�g�p�s�N�Z���V�F�[�_�[
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#include "MikuMikuFlex.hlsli"
#include "DefaultVS_OUTPUT.hlsli"


SamplerState mySampler
{
    Filter = MIN_MAG_LINEAR_MIP_POINT;
    AddressU = WRAP;
    AddressV = WRAP;
};


float4 main(VS_OUTPUT IN) : SV_TARGET
{
    // ���ːF�v�Z
	
    float3 LightDirection = normalize(mul(Light1Direction, WorldMatrix * ViewMatrix)).xyz;
    float3 HalfVector = normalize(normalize(IN.Eye) - mul(float4(LightDirection, 0), WorldMatrix * ViewMatrix).xyz);
    float3 Specular = pow(max(0.00001, dot(HalfVector, normalize(IN.Normal))), SpecularPower) * SpecularColor.rgb;
    float4 Color = IN.Color;


	// �e�N�X�`���T���v�����O

    if (UseTexture)
    {
        Color *= Texture.Sample(mySampler, IN.Tex);
    }

	// �X�t�B�A�}�b�v�T���v�����O

    if (UseSphereMap)
    {
        if (IsAddSphere)
        {
            Color.rgb += SphereTexture.Sample(mySampler, IN.SpTex).rgb; // ���Z
        }
        else
        {
            Color.rgb *= SphereTexture.Sample(mySampler, IN.SpTex).rgb; // ��Z
        }
    }

	
	// �V�F�[�f�B���O

    //float LightNormal = dot(IN.Normal, -mul(float4(LightDirection, 0), matWV).xyz);
    float LightNormal = dot(IN.Normal, -LightDirection.xyz);
    float shading = saturate(LightNormal); // 0�`1 �Ɋۂ߂�

	
	// �g�D�[���e�N�X�`���T���v�����O
	
    if (UseToonTextureMap)
    {
        float3 MaterialToon = ToonTexture.Sample(mySampler, float2(0, shading)).rgb;
        Color.rgb *= MaterialToon;
    }
    else
    {
        //float3 MaterialToon = 1.0f.xxx * shading;
        float3 MaterialToon = 1.0f.xxx * (0.85f + shading * 0.15f); // shading:0��1 �̂Ƃ��AMaerialToon: 0.85��1.0
        Color.rgb *= MaterialToon;
    }
    
    
    // �F�ɔ��ˌ������Z

    Color.rgb += Specular;

	
	// �F�Ɋ��������Z

	//Color.rgb += AmbientColor.rgb * 0.2;	//TODO MMD��Ambient�̌W�����킩���E�E�E
    Color.rgb += AmbientColor.rgb * 0.005;

    return Color;
}
