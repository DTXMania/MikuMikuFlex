///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Skinning.hlsli
// �@�X�L�j���O�Ŏg�p�����f�[�^�̒�`�B
// �@�����͌Œ�`���f�[�^�Ƃ��ăv���O�������Ƀn�[�h�R�[�f�B���O����Ă���̂ŁA
// �@�v���O�����Ƃ̘A�g�Ȃ��ɉ��ς��Ă͂Ȃ�Ȃ��B
//
////////////////////////////////////////////////////////////////////////////////////////////////////

// �X�L�j���O�Ŏg�p�ł���{�[���ό`�̎��
#define DEFORM_BDEF1    0
#define DEFORM_BDEF2    1
#define DEFORM_BDEF4    2
#define DEFORM_SDEF     3
#define DEFORM_QDEF     4

// �X�L�j���O�p�R���s���[�g�V�F�[�_�[��������{�[�����̍ő吔
#define MAX_BONE    768


// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓��́F�萔�o�b�t�@(1) �{�[���̃��f���|�[�Y�s��̔z��
cbuffer BoneTransBuffer : register(b1)
{
	float4x4 g_BoneTrans[MAX_BONE];
}

// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓��́F�萔�o�b�t�@(2) �{�[���̃��[�J���ʒu�̔z��iSDEF�Ŏg�p�j
cbuffer BoneLocalPositionBuffer : register(b2)
{
	float4 g_BoneLocalPosition[MAX_BONE];
}

// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓��́F�萔�o�b�t�@(3) �{�[���̉�]�i�N�H�[�^�j�I���j�̔z��iSDEF�ł̂ݎg�p����j
cbuffer BoneQuaternionBuffer : register(b3)
{
	float4 g_BoneQuaternion[MAX_BONE];
}


// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓��́F���_�̍\��
struct CS_BDEF_INPUT
{
	float4 Position;
	float BoneWeight1;
	float BoneWeight2;
	float BoneWeight3;
	float BoneWeight4;
	uint BoneIndex1;
	uint BoneIndex2;
	uint BoneIndex3;
	uint BoneIndex4;
	float3 Normal;
	float2 Tex;
	float4 AddUV1;
	float4 AddUV2;
	float4 AddUV3;
	float4 AddUV4;
	float4 Sdef_C;
	float3 Sdef_R0;
	float3 Sdef_R1;
	float EdgeWeight;
	uint Index;
	uint Deform;
};

// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓��́F���_�̍\�����o�b�t�@
StructuredBuffer<CS_BDEF_INPUT> g_CSBDEFBuffer : register(t0);


// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̏o�́F���_�o�b�t�@�iRW�o�C�g�A�h���X�o�b�t�@�j
// �� ���̃o�b�t�@�́A���̂܂ܒ��_�V�F�[�_�̓��́i���_�o�b�t�@�j�Ƃ��Ďg�p�����B
RWByteAddressBuffer g_VSBuffer : register(u0);

