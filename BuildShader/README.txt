//////////////////////////////////////////
//
// �V�F�[�_�[�t�@�C��(.hlsl)�Ƃ��ꂪ�C���N���[�h����t�@�C��(.hlsli)�̑Ή��\
//


// �X�L�j���O�p�R���s���[�g�V�F�[�_�[						; ���\�[�X�o�C���f�B���O

DefaultSkinningComputeShader.hlsl
	Skinning.hlsli	... ���o�͒�`�i�ύX�s�j				; b1, b2, b3, t0, u0
	VS_INPUT.hlsli	... �o�͒�`�i�ύX�s�j


// ���_�V�F�[�_�[

DefaultVertexShaderForObject.hlsl
DefaultVertexShaderForEdge.hlsl
	GlobalParameters.hlsli	... ���͒�`�i�ύX�s�j		; b0
	VS_INPUT.hlsli			... ���͒�`�i�ύX�s�j
	DefaultVS_OUTPUT.hlsli	... �o�͒�`


// �n���V�F�[�_�[

DefaultHullShader.hlsl
	GlobalParameters.hlsli			... ���͒�`�i�ύX�s�j; b0
	DefaultVS_OUTPUT.hlsli			... ���o�͒�`
	DefaultCONSTANT_HS_OUT.hlsli	... �o�͒�`


// �h���C���V�F�[�_�[

DefaultDomainShader.hlsl
	GlobalParameters.hlsli			... ���͒�`�i�ύX�s�j; b0
	DefaultVS_OUTPUT.hlsli			... ���o�͒�`
	DefaultCONSTANT_HS_OUT.hlsli	... ���͒�`


// �W�I���g���V�F�[�_�[

DefaultGeometryShader.hlsl
	GlobalParameters.hlsli	... ���͒�`�i�ύX�s�j		; b0
	DefaultGS_OUTPUT.hlsli	... �o�͒�`


// �s�N�Z���V�F�[�_�[

DefaultPixelShaderForObject.hlsl
DefaultPixelShaderForEdge.hlsl
	GlobalParameters.hlsli	... ���͒�`�i�ύX�s�j		; b0
	MaterialTexture.hlsli	... ���͒�`�i�ύX�s�j		; t0, t1, t2
	DefaultVS_OUTPUT.hlsli	... ���͒�`
