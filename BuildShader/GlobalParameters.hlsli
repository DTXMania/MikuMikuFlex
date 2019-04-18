////////////////////////////////////////////////////////////////////////////////////////////////////
//
// GlobalParameters.hlsli
// �@�V�F�[�_�[�p�O���[�o���p�����[�^�[�萔�o�b�t�@�B
// �@�v���O��������V�F�[�_�[�ɓn������ʓI�ȃp�����[�^�B
//
// �@�����͌Œ�`���f�[�^�Ƃ��ăv���O�������Ƀn�[�h�R�[�f�B���O����Ă���̂ŁA
// �@�v���O�����Ƃ̘A�g�Ȃ��ɉ��ς��Ă͂Ȃ�Ȃ��B
//
// ���l�F
// �@�e�p�����[�^�́A�ݒ�E�X�V�����^�C�~���O�ɂ���āA�ȉ��̂悤�ɕ�������B
//
// �@�V�[���P�� �c�c �V�[�����̂��ׂẴ��f���ɂ��ē���ł���p�����[�^�B
// �@���f���P�� �c�c ���f�����̂��ׂĂ̍ގ��ɂ��ē���ł���p�����[�^�B
// �@���f���P�� �c�c ���f�����̍ގ����ƂɈقȂ�p�����[�^�B
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#define GlobalParametersVersion 1


cbuffer GlobalParameters : register(b0)
{
    // �`�撆�̍ގ����X�t�B�A�}�b�v���g�p����Ȃ� true�B�ގ��P�ʁB
    // �@true �̏ꍇ�ASphereTexture �I�u�W�F�N�g���L���ł��邱�ƁB
    bool g_UseSphereMap; // HLSL��bool��4byte

    // �X�t�B�A�}�b�v�̎�ށBtrue �Ȃ���Z�X�t�B�A�Afalse �Ȃ��Z�X�t�B�A�B�ގ��P�ʁB
    bool g_IsAddSphere;

    // �`�撆�̍ގ����e�N�X�`�����g�p����Ȃ� true�B�ގ��P�ʁB
    // �@true �̏ꍇ�ATexture �I�u�W�F�N�g���L���ł��邱�ƁB
    bool g_UseTexture;

    // �`�撆�̍ގ����g�D�[���e�N�X�`�����g�p����Ȃ� true�B�ގ��P�ʁB
    // �@true �̏ꍇ�AToonTexture �I�u�W�F�N�g���L���ł��邱�ƁB
    bool g_UseToonTextureMap;

    // �`�撆�̍ގ����Z���t�e���g�p����Ȃ� true�B�ގ��P�ʁB
    bool g_UseSelfShadow;

	// ���[���h�ϊ��s��B���f���P�ʁB
	float4x4 g_WorldMatrix;

	// �r���[�ϊ��s��B�V�[���P�ʁB
    float4x4 g_ViewMatrix;

    // �ˉe�ϊ��s��B�V�[���P�ʁB
    float4x4 g_ProjectionMatrix;

    // �J�����̈ʒu�B�V�[���P�ʁB
    float4 g_CameraPosition;

    // �J�����̒����_�B�V�[���P�ʁB
    float4 g_CameraTargetPosition;

    // �J�����̏�����������x�N�g���B�V�[���P�ʁB
    float4 g_CameraUp;

    // �Ɩ��P�̐F�B�V�[���P�ʁB
    float4 g_Light1Color;

    // �Ɩ��P�̕����B�V�[���P�ʁB
    float4 g_Light1Direction;

    // �Ɩ��Q�̐F�B�V�[���P�ʁB
    float4 g_Light2Color;

    // �Ɩ��Q�̕����B�V�[���P�ʁB
    float4 g_Light2Direction;

    // �Ɩ��R�̐F�B�V�[���P�ʁB
    float4 g_Light3Color;

    // �Ɩ��R�̕����B�V�[���P�ʁB
    float4 g_Light3Direction;

    // �����B�ގ��P�ʁB
    float4 g_AmbientColor;

    // �g�U�F�B�ގ��P�ʁB
    float4 g_DiffuseColor;

    // ���ːF�B�ގ��P�ʁB
    float4 g_SpecularColor;

	// �G�b�W�̐F�B�ގ��P�ʁB
	float4 g_EdgeColor;
	
	// ���ˌW���B�ގ��P�ʁB
    float g_SpecularPower;

    // �G�b�W�̕��B�ގ��P�ʁB
    float g_EdgeWidth;

    // �e�b�Z���[�V�����W���B���f���P�ʁB
    float g_TessellationFactor;

	// �r���[�|�[�g�̕��ƍ����B�V�[���P�ʁB
	float2 g_ViewportSize;
}
