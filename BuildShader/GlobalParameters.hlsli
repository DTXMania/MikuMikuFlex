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
// �@�X�e�[�W�P�� �c�c �X�e�[�W���̂��ׂẴ��f���ɂ��ē���ł���p�����[�^�B
// �@���f���P�� �c�c�c ���f�����̂��ׂĂ̍ގ��ɂ��ē���ł���p�����[�^�B
// �@���f���P�� �c�c�c ���f�����̍ގ����ƂɈقȂ�p�����[�^�B
//
////////////////////////////////////////////////////////////////////////////////////////////////////


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

	// �G�b�W�̐F�B�ގ��P�ʁB
	float4 EdgeColor;
	
	// ���ˌW���B�ގ��P�ʁB
    float SpecularPower;

    // �G�b�W�̕��B�ގ��P�ʁB
    float EdgeWidth;

    // �e�b�Z���[�V�����W���B���f���P�ʁB
    float TessellationFactor;
}
