////////////////////////////////////////////////////////////////////////////////////////////////////
//
// �{�[���ό`�p�R���s���[�g�V�F�[�_�[
//
// �@���f���ɑ΂���X�L�j���O�i�{�[���̈ʒu�ɒǏ]���Ē��_�ʒu���ړ��i�{�[���ό`�j�����Ɓj���A
// �@�R���s���[�g�V�F�[�_�[���g���čs���B
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#include "VS_INPUT.hlsli"
#include "Skinning.hlsli"
#include "Quaternion.hlsli"


void BDEF(CS_BDEF_INPUT input, out float4 position, out float3 normal)
{
	float4x4 bt =
		mul(g_BoneTrans[input.BoneIndex1], input.BoneWeight1) +
		mul(g_BoneTrans[input.BoneIndex2], input.BoneWeight2) +
		mul(g_BoneTrans[input.BoneIndex3], input.BoneWeight3) +
		mul(g_BoneTrans[input.BoneIndex4], input.BoneWeight4);

    position = mul(input.Position, bt);
    normal = normalize(mul(input.Normal, (float3x3) bt));
}

void SDEF(CS_BDEF_INPUT input, out float4 position, out float3 normal)
{
    // �Q�l: 
    // �����p�����uPMX�̃X�t�B���J���f�t�H�[���̃R�[�h���ۂ����́v�isma42���j
    // https://www.pixiv.net/member_illust.php?mode=medium&illust_id=60755964

    float w0 = 0.0f; // �Œ�l�ł���SDEF�p�����[�^�ɂ݈̂ˑ�����̂ŁA�����̒l�����͌Œ�l�B
    float w1 = 0.0f; //

    float L0 = length(input.Sdef_R0 - g_BoneLocalPosition[input.BoneIndex2].xyz); // �q�{�[������R0�܂ł̋���
    float L1 = length(input.Sdef_R1 - g_BoneLocalPosition[input.BoneIndex2].xyz); // �q�{�[������R1�܂ł̋���

    if (abs(L0 - L1) < 0.0001f)
    {
        w0 = 0.5f;
    }
    else
    {
        w0 = saturate(L0 / (L0 + L1));
    }
    w1 = 1.0f - w0;

	float4x4 modelPoseL = mul(g_BoneTrans[input.BoneIndex1], input.BoneWeight1);
	float4x4 modelPoseR = mul(g_BoneTrans[input.BoneIndex2], input.BoneWeight2);
    float4x4 modelPoseC = modelPoseL + modelPoseR;

    float4 Cpos = mul(input.Sdef_C, modelPoseC); // BDEF2�Ōv�Z���ꂽ�_C�̈ʒu
    float4 Ppos = mul(input.Position, modelPoseC); // BDEF2�Ōv�Z���ꂽ���_�̈ʒu

    float4 qp = quaternion_slerp(
		mul(g_BoneQuaternion[input.BoneIndex1], input.BoneWeight1),
		mul(g_BoneQuaternion[input.BoneIndex2], input.BoneWeight2),
        input.BoneWeight1);
    float4x4 qpm = quaternion_to_matrix(qp);

    float4 R0pos = mul(float4(input.Sdef_R0, 1.0f), (modelPoseL + mul(modelPoseC, -input.BoneWeight1)));
    float4 R1pos = mul(float4(input.Sdef_R1, 1.0f), (modelPoseR + mul(modelPoseC, -input.BoneWeight2)));
    Cpos += mul(R0pos, w0) + mul(R1pos, w1); // �c��݂����h�~�H

    Ppos -= Cpos; // ���_��_C�����S�ɂȂ�悤�ړ�����
    Ppos = mul(Ppos, qpm); // ��]����
    Ppos += Cpos; // ���̈ʒu��

    position = Ppos;
    normal = normalize(mul(float4(input.Normal, 0), qpm)).xyz;
}

void QDEF(CS_BDEF_INPUT input, out float4 position, out float3 normal)
{
    // TODO: QDEF �̎����ɕύX����B�i���܂�BDEF4�Ɠ����j

    float4x4 bt =
		mul(g_BoneTrans[input.BoneIndex1], input.BoneWeight1) +
		mul(g_BoneTrans[input.BoneIndex2], input.BoneWeight2) +
		mul(g_BoneTrans[input.BoneIndex3], input.BoneWeight3) +
		mul(g_BoneTrans[input.BoneIndex4], input.BoneWeight4);

    position = mul(input.Position, bt);
    normal = normalize(mul(float4(input.Normal, 0), bt)).xyz;
}


////////////////////
//
// �R���s���[�g�V�F�[�_�[
//
// �@X��������Ȃ��̂ŁADispach �� (���_��/64+1, 1, 1) �Ƃ��邱�ƁB
// �@��: ���_���� 130 �Ȃ� Dispach( 3, 1, 1 )
//

[numthreads(64, 1, 1)]
void main(uint3 id : SV_DispatchThreadID)
{
    uint csIndex = id.x; // ���_�ԍ��i0�`���_��-1�j
    uint vsIndex = csIndex * VS_INPUT_SIZE; // �o�͈ʒu[byte�P�ʁi�K��4�̔{���ł��邱�Ɓj]

    CS_BDEF_INPUT input = g_CSBDEFBuffer[csIndex];

    // �{�[���E�F�C�g�ό`��K�p���āA�V�����ʒu�Ɩ@�������߂�B

    float4 position = input.Position;
    float3 normal = input.Normal;

    switch (input.Deform)
    {
        case DEFORM_BDEF1:
        case DEFORM_BDEF2:
        case DEFORM_BDEF4:
            BDEF(input, position, normal);
            break;

        case DEFORM_SDEF:
            SDEF(input, position, normal);
            break;

        case DEFORM_QDEF:
            QDEF(input, position, normal);
            break;
    }

    
    // ���_�o�b�t�@�֏o�͂���B

	g_VSBuffer.Store4(vsIndex + 0, asuint(position));
	g_VSBuffer.Store3(vsIndex + 16, asuint(normal));
	g_VSBuffer.Store2(vsIndex + 28, asuint(input.Tex));
	g_VSBuffer.Store4(vsIndex + 36, asuint(input.AddUV1));
	g_VSBuffer.Store4(vsIndex + 52, asuint(input.AddUV2));
	g_VSBuffer.Store4(vsIndex + 68, asuint(input.AddUV3));
	g_VSBuffer.Store4(vsIndex + 84, asuint(input.AddUV4));
	g_VSBuffer.Store(vsIndex + 100, asuint(input.EdgeWeight));
	g_VSBuffer.Store(vsIndex + 104, asuint(input.Index));
}
