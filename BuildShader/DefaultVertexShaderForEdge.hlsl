////////////////////////////////////////////////////////////////////////////////////////////////////
//
// �G�b�W�p���_�V�F�[�_�[
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#include "VS_INPUT.hlsli"
#include "DefaultVS_OUTPUT.hlsli"
#include "GlobalParameters.hlsli"

VS_OUTPUT main(VS_INPUT input)
{
    VS_OUTPUT Out = (VS_OUTPUT) 0;

	// ���_�@��
    Out.Normal = normalize(mul(input.Normal, (float3x3) WorldMatrix));

	// �ʒu
    float4 position = input.Position;
    // �@�������ɖc��܂���B
    position = input.Position + float4(Out.Normal, 0) * EdgeWidth * input.EdgeWeight * distance(input.Position.xyz, CameraPosition.xyz) * 0.0005;
    Out.Position = mul(position, WorldMatrix); // ���[���h�ϊ�

	// �J�����Ƃ̑��Έʒu
    Out.Eye = (CameraPosition - mul(input.Position, WorldMatrix)).xyz;

	// �f�B�t���[�Y�F�v�Z
    Out.Color.rgb = DiffuseColor.rgb;
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate(Out.Color); // 0�`1 �Ɋۂ߂�

    Out.Tex = input.Tex;

    if (UseSphereMap)
    {
		// �X�t�B�A�}�b�v�e�N�X�`�����W
        float2 NormalWV = mul(float4(Out.Normal, 0), ViewMatrix).xy;
        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }
    else
    {
        Out.SpTex.x = 0.0f;
        Out.SpTex.y = 0.0f;
    }

    return Out;
}
