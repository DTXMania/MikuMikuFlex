///////////////////////////////////////////////////////////////////////////////////////////////////
//
// VS_INPUT.hlsli
// �@�����͌Œ�`���f�[�^�Ƃ��ăv���O�������Ƀn�[�h�R�[�f�B���O����Ă���̂ŁA
// �@�v���O�����Ƃ̘A�g�Ȃ��ɉ��ς��Ă͂Ȃ�Ȃ��B
//
////////////////////////////////////////////////////////////////////////////////////////////////////

// ���_�V�F�[�_�[�̓��́i���X�L�j���O�p�R���s���[�g�V�F�[�_�[�̏o�́j�F���_�̍\��
struct VS_INPUT
{
	float4 Position : POSITION; // �X�L�j���O��̍��W�i���[�J�����W�j
	float3 Normal : NORMAL; // �@���i���[�J�����W�j
	float2 Tex : TEXCOORD0; // UV
	float4 AddUV1 : TEXCOORD1; // �ǉ�UV1
	float4 AddUV2 : TEXCOORD2; // �ǉ�UV2
	float4 AddUV3 : TEXCOORD3; // �ǉ�UV3
	float4 AddUV4 : TEXCOORD4; // �ǉ�UV4
	float EdgeWeight : EDGEWEIGHT; // �G�b�W�E�F�C�g
	uint Index : PSIZE15; // ���_�C���f�b�N�X�l
};

// �X�L�j���O�p�R���s���[�g�V�F�[�_�[���o�͂��钸�_�̃T�C�Y
#define VS_INPUT_SIZE  ((4+3+2+4+4+4+4+1+1)*4)
