////////////////////////////////////////////////////////////////////////////////////////////////////
//
// MikuMikuFlex.hlsli
// �Œ肳���f�[�^�̒�`�B
// �@�����͌Œ�`���f�[�^�Ƃ��ăv���O�������Ƀn�[�h�R�[�f�B���O����Ă���̂ŁA
// �@�v���O�����Ƃ̘A�g�Ȃ��ɉ��ς��Ă͂Ȃ�Ȃ��B
//
////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////
//
// �Œ�f�[�^(1) �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓���
//


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
    float4x4 BoneTrans[MAX_BONE];
}

// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓��́F�萔�o�b�t�@(2) �{�[���̃��[�J���ʒu�̔z��iSDEF�Ŏg�p�j
cbuffer BoneLocalPositionBuffer : register(b2)
{
    float3 BoneLocalPosition[MAX_BONE];
}

// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓��́F�萔�o�b�t�@(3) �{�[���̉�]�i�N�H�[�^�j�I���j�̔z��iSDEF�ł̂ݎg�p����j
cbuffer BoneQuaternionBuffer : register(b3)
{
    float4 BoneQuaternion[MAX_BONE];
}

// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̓��́F���_�̍\��
struct CS_BDEF_INPUT
{
    float4 Position;
    float4 BoneWeight;
    uint4 BoneIndex;
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
StructuredBuffer<CS_BDEF_INPUT> CSBDEFBuffer : register(t0);



////////////////////
//
// �Œ�f�[�^(2) �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̏o�́i�� ���_�V�F�[�_�[�̓��́j
//


// �X�L�j���O�p�R���s���[�g�V�F�[�_�[�̏o�́F���_�o�b�t�@�iRW�o�C�g�A�h���X�o�b�t�@�j
// �� ���̃o�b�t�@�́A���̂܂ܒ��_�V�F�[�_�̓��́i���_�o�b�t�@�j�Ƃ��Ďg�p�����B
RWByteAddressBuffer VSBuffer : register(u0);

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



////////////////////
//
// �Œ�f�[�^(3) �e�N�X�`��
//


// �s�N�Z���V�F�[�_�[�̓��́F�ʏ�e�N�X�`��
Texture2D Texture : register(t1);

// �s�N�Z���V�F�[�_�[�̓��́F�X�t�B�A�}�b�v�e�N�X�`��
Texture2D SphereTexture : register(t2);

// �s�N�Z���V�F�[�_�[�̓��́F�g�D�[���e�N�X�`��
Texture2D ToonTexture : register(t3);




////////////////////
//
// �Œ�f�[�^(4) �V�F�[�_�[�p�O���[�o���p�����[�^�[�萔�o�b�t�@
// �@�v���O��������V�F�[�_�[�ɓn������ʓI�ȃp�����[�^�B
//
// ���l�F
// �@�e�p�����[�^�́A�ݒ�E�X�V�����^�C�~���O�ɂ���āA�ȉ��̂悤�ɕ�������B
//
// �@�X�e�[�W�P�� �c�c �X�e�[�W���̂��ׂẴ��f���ɂ��ē���ł���p�����[�^�B
// �@���f���P�� �c�c�c ���f�����̂��ׂĂ̍ގ��ɂ��ē���ł���p�����[�^�B
// �@���f���P�� �c�c�c ���f�����̍ގ����ƂɈقȂ�p�����[�^�B
//

cbuffer GlobalParameters : register(b0)
{
    
    // �R���g���[���t���O


    // �`�撆�̍ގ����X�t�B�A�}�b�v���g�p����Ȃ� true�B�ގ��P�ʁB
    // �@true �̏ꍇ�ASphereTexture �I�u�W�F�N�g���L���ł��邱�ƁB
    bool UseSphereMap; // HLSL��bool��4byte

    // �X�t�B�A�}�b�v�̎�ށBtrue �Ȃ���Z�X�t�B�A�Afalse �Ȃ��Z�X�t�B�A�B�ގ��P�ʁB
    bool IsAddSphere;

    // �`�撆�̍ގ����e�N�X�`�����g�p����Ȃ� true�B�ގ��P�ʁB
    // �@true �̏ꍇ�ATexture �I�u�W�F�N�g���L���ł��邱�ƁB
    bool UseTexture;

    // �`�撆�̍ގ����g�D�[���e�N�X�`�����g�p����Ȃ� true�B�ގ��P�ʁB
    // �@true �̏ꍇ�AToonTexture �I�u�W�F�N�g���L���ł��邱�ƁB
    bool UseToonTextureMap;

    // �`�撆�̍ގ����Z���t�e���g�p����Ȃ� true�B�ގ��P�ʁB
    bool UseSelfShadow;



    // ���[���h�r���[�ˉe�ϊ�


    // ���[���h�ϊ��s��B���f���P�ʁB
    float4x4 WorldMatrix;

    // �r���[�ϊ��s��B�X�e�[�W�P�ʁB
    float4x4 ViewMatrix;

    // �ˉe�ϊ��s��B�X�e�[�W�P�ʁB
    float4x4 ProjectionMatrix;



    // �J����


    // �J�����̈ʒu�B�X�e�[�W�P�ʁB
    float4 CameraPosition;

    // �J�����̒����_�B�X�e�[�W�P�ʁB
    float4 CameraTargetPosition;

    // �J�����̏�����������x�N�g���B�X�e�[�W�P�ʁB
    float4 CameraUp;



    // �Ɩ�
    // �@��MMM�ł͏Ɩ��P�`�R�𓯎��Ɏg�p�\�B�iMMD�ł͏Ɩ��P�̂݁j

    // �Ɩ��P�̐F�B�X�e�[�W�P�ʁB
    float4 Light1Color;

    // �Ɩ��P�̕����B�X�e�[�W�P�ʁB
    float4 Light1Direction;

    // �Ɩ��Q�̐F�B�X�e�[�W�P�ʁB
    float4 Light2Color;

    // �Ɩ��Q�̕����B�X�e�[�W�P�ʁB
    float4 Light2Direction;

    // �Ɩ��R�̐F�B�X�e�[�W�P�ʁB
    float4 Light3Color;

    // �Ɩ��R�̕����B�X�e�[�W�P�ʁB
    float4 Light3Direction;



    // �ގ�


    // �����B�ގ��P�ʁB
    float4 AmbientColor;

    // �g�U�F�B�ގ��P�ʁB
    float4 DiffuseColor;

    // ���ːF�B�ގ��P�ʁB
    float4 SpecularColor;

    // ���ˌW���B�ގ��P�ʁB
    float SpecularPower;

    // �G�b�W�̐F�B�ގ��P�ʁB
    float4 EdgeColor;

    // �G�b�W�̕��B�ގ��P�ʁB
    float EdgeWidth;

    // �e�b�Z���[�V�����W���B���f���P�ʁB
    float TessellationFactor;
}
