//
// �T���v���V�[���G�t�F�N�g
//


// Script �錾 ///////////////////////////////////////////


float Script : STANDARDSGLOBAL <
	string ScriptClass="sceneorobject"; // �s��֘A�̃Z�}���e�B�N�X�� Object�ACURRENTSCENE*�Z�}���e�B�N�X�� Scene
	string Script="";
> = 0.8;


// �O���[�o���ϐ� ///////////////////////////////////////////

float2   viewportSize  : VIEWPORTPIXELSIZE;
Texture2D SceneTexture : CURRENTSCENECOLOR;          // �V�[���p�e�N�X�`��

SamplerState SceneSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};


// �V�[���`�� ////////////////////////////////////////////////


// ���_�V�F�[�_�o��

struct SCENE_VS_OUTPUT
{
    float4 Position : SV_POSITION; // ���_���W�i�ˉe���W�n�j
    float2 Tex      : TEXCOORD0;   // �e�N�X�`�����W
};

// ���_�V�F�[�_�[

SCENE_VS_OUTPUT VS_Scene( uint vID : SV_VertexID )
{
    SCENE_VS_OUTPUT vt;
    
    // ���_���W�i�ˉe���W�n�j�̎�������
    // �v���~�e�B�u�^�Ƃ��� TriangleStrip ���ݒ肳��Ă���O��Ȃ̂Œ��ӁB
    float z = 0;
    switch (vID)
    {
        case 0:
            vt.Position = float4(-1, 1, z, 1.0); // ����
            vt.Tex = float2(0, 0);
            break;
        case 1:
            vt.Position = float4(1, 1, z, 1.0); // �E��
            vt.Tex = float2(1, 0);
            break;
        case 2:
            vt.Position = float4(-1, -1, z, 1.0); // ����
            vt.Tex = float2(0, 1);
            break;
        case 3:
            vt.Position = float4(1, -1, z, 1.0); // �E��
            vt.Tex = float2(1, 1);
            break;
    }

    return vt;
}


// �s�N�Z���V�F�[�_�[

float4 PS_Scene( SCENE_VS_OUTPUT input ) : SV_Target
{
    // CURRENTSCENECOLOR �Z�}���e�B�N�X���t�^���ꂽ Texture2D �ϐ��ɂ́A
    // ���݂܂ł̕`����e�i�o�b�N�o�b�t�@�̃R�s�[�j���i�[����Ă���B

    float4 texCol = SceneTexture.Sample(SceneSampler, input.Tex);
    texCol.a = 1;

    //return texCol;    // �������H���Ȃ���
    return saturate(texCol * float4(input.Tex.x, input.Tex.y, 0.5, 1)); // �O���f���悶���
}


// �e�N�j�b�N�ƃp�X

technique11 DefaultScene < string MMDPass = "scene"; >
{
    pass DefaultPass
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Scene()));
        SetPixelShader(CompileShader(ps_5_0, PS_Scene()));
    }
}
