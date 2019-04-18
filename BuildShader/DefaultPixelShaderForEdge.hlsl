////////////////////////////////////////////////////////////////////////////////////////////////////
//
// �G�b�W�p�s�N�Z���V�F�[�_�[
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#include "MaterialTexture.hlsli"
#include "DefaultVS_OUTPUT.hlsli"
#include "GlobalParameters.hlsli"


SamplerState mySampler : register(s0);


float4 main(VS_OUTPUT IN) : SV_TARGET
{
	float4 Color = g_EdgeColor;

	if (g_UseTexture)
	{
		// �����x�̓e�N�X�`���ɍ��킹��
		Color.a = g_Texture.Sample(mySampler, IN.Tex).a;
	}

	return Color;
}
