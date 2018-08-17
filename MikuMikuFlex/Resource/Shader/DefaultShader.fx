
float Script : STANDARDSGLOBAL <
	string ScriptClass="scene";
	string Script="";
> = 0.8;


// �ϊ��s��n

float4x4 matWVP : WORLDVIEWPROJECTION < string Object="Camera"; >;
float4x4 matWV:WORLDVIEW < string Object = "Camera"; >;
float4x4 WorldMatrix : WORLD;
float4x4 ViewMatrix : VIEW;

float2 viewportSize : VIEWPORTPIXELSIZE;

float4 ViewPointPosition : POSITION < string object="camera"; >;
float4 LightPointPosition : POSITION < string object="light"; >;


// �X�L�j���O

float4x4 BoneTrans[768] : BONETRANS;


// �ގ�


// �T���v�����O�p�e�N�X�`��
Texture2D Texture : MATERIALTEXTURE;

// �T���v�����O�p�X�t�B�A�}�b�v�e�N�X�`��
Texture2D SphereTexture : MATERIALSPHEREMAP;

// �T���v�����O�p�g�D�[���e�N�X�`��
Texture2D Toon : MATERIALTOONTEXTURE;


// ����p�����[�^


// �`�撆�̍ގ����X�t�B�A�}�b�v���g�p����Ȃ� true
bool use_spheremap;

// �X�t�B�A�}�b�v���g���ꍇ�̃I�v�V�����B
// true: ���Z�X�t�B�A�Afalse: ��Z�X�t�B�A
bool spadd;

// �`�撆�̍ގ����e�N�X�`�����g�p����Ȃ� true
bool use_texture;

// �`�撆�̍ގ����g�D�[���e�N�X�`�����g�p����Ȃ� true
bool use_toon;


// �ގ��P�ʂŕς��Ȃ�����

cbuffer BasicMaterialConstant
{
	float4 AmbientColor:packoffset(c0);
	float4 DiffuseColor:packoffset(c1);
	float4 SpecularColor:packoffset(c2);
	float SpecularPower:packoffset(c3);
}


/////////////////////////////////////////////
// �T���v���[�X�e�[�g

// �e�N�X�`���A�X�t�B�A�}�b�v�A�g�D�[���e�N�X�`���ŋ���
SamplerState mySampler
{
   Filter = MIN_MAG_LINEAR_MIP_POINT;
   AddressU = WRAP;
   AddressV = WRAP;
};

/////////////////////////////////////////////
// �V�F�[�_�[���o��


// ���_�V�F�[�_���́iMMM�����j
struct MMM_SKINNING_INPUT
{
	float4 Pos : POSITION;//���_�ʒu
	float4 BoneWeight : BLENDWEIGHT;
	uint4 BlendIndices : BLENDINDICES;
	float3 Normal : NORMAL;
	float2 Tex : TEXCOORD0;
	float4 AddUV1 : TEXCOORD1;
	float4 AddUV2 : TEXCOORD2;
	float4 AddUV3 : TEXCOORD3;
	float4 AddUV4 : TEXCOORD4;
	float4 SdefC : TEXCOORD5;
	float3 SdefR0 : TEXCOORD6;
	float3 SdefR1 : TEXCOORD7;
	float EdgeWeight : TEXCOORD8;
	uint Index : PSIZE15;
};

// ���_�V�F�[�_�o�́i���s�N�Z���V�F�[�_���́j
struct VS_OUTPUT
{
	float4 Pos		: SV_Position;
    float2 Tex		: TEXCOORD1;   // �e�N�X�`��
    float3 Normal	: TEXCOORD2;   // �@��
    float3 Eye		: TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex	: TEXCOORD4;   // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color	: COLOR0;      // �f�B�t���[�Y�F
};


/////////////////////////////////////////////
// ���_�V�F�[�_����

VS_OUTPUT VS_Main( MMM_SKINNING_INPUT input, uint vid:SV_VertexID )
{    
	VS_OUTPUT Out;
	
	// �X�L�����b�V���A�j���[�V����
	float4x4 bt =
		BoneTrans[ input.BlendIndices[0] ] * input.BoneWeight[0] + 
		BoneTrans[ input.BlendIndices[1] ] * input.BoneWeight[1] + 
		BoneTrans[ input.BlendIndices[2] ] * input.BoneWeight[2] + 
		BoneTrans[ input.BlendIndices[3] ] * input.BoneWeight[3];

	// �ʒu�i���[���h�r���[�ˉe�ϊ��j
	Out.Pos = mul( input.Pos, mul( bt, matWVP ) );
	
	// �J�����Ƃ̑��Έʒu
    Out.Eye = ViewPointPosition - mul( input.Pos, WorldMatrix );
	
	// ���_�@��
    Out.Normal = normalize( mul( input.Normal, (float3x3)WorldMatrix ) );
	
	// �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = DiffuseColor.rgb;
	Out.Color.a = DiffuseColor.a;
	Out.Color = saturate( Out.Color );	// 0�`1 �Ɋۂ߂�
	
	Out.Tex = input.Tex;
	
    if ( use_spheremap )
	{
        // �X�t�B�A�}�b�v�e�N�X�`�����W
        float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }
    
	return Out;
}


/////////////////////////////////////////////
// �s�N�Z���V�F�[�_����

float4 PS_Main( VS_OUTPUT IN ) : SV_Target
{
    // ���ːF�v�Z
	
	float3 LightDirection = -normalize( mul( LightPointPosition, matWV ) );
	float3 HalfVector = normalize(normalize( IN.Eye ) + -mul( LightDirection, matWV ) );
    float3 Specular = pow( max( 0.00001, dot( HalfVector, normalize( IN.Normal ) ) ), SpecularPower ) * SpecularColor.rgb;
	float4 Color = IN.Color;


	// �e�N�X�`���T���v�����O

	if( use_texture )
	{
		Color *= Texture.Sample( mySampler, IN.Tex );
	}


	// �X�t�B�A�}�b�v�T���v�����O

	if ( use_spheremap )
	{
		if( spadd )
		{
			Color.rgb += SphereTexture.Sample(mySampler, IN.SpTex).rgb;	// ���Z
		}
		else
		{
			Color.rgb *= SphereTexture.Sample(mySampler, IN.SpTex).rgb;	// ��Z
		}
    }

	
	// �V�F�[�f�B���O

	float LightNormal = dot( IN.Normal, -mul( LightDirection,matWV ) );
	float shading = saturate( LightNormal );	// 0�`1 �Ɋۂ߂�
    
	
	// �g�D�[���e�N�X�`���T���v�����O
	
	if ( use_toon )
	{
        float3 MaterialToon = Toon.Sample( mySampler, float2( 0, shading ) ).rgb;
        Color.rgb *= MaterialToon;
    }
	else
	{
        float3 MaterialToon = 1.0.xxx * shading;
        Color.rgb *= MaterialToon;
	}
    
    
    // �F�ɔ��ˌ������Z

    Color.rgb += Specular;

	
	// �F�Ɋ��Z�����Z

	//Color.rgb += AmbientColor.rgb * 0.2;	//TODO MMD��Ambient�̌W�����킩���E�E�E
	Color.rgb += AmbientColor.rgb * 0.05;

	return Color;
}


/////////////////////////////////////////////
//�e�N�j�b�N

technique10 DefaultTechnique < string MMDPass = "object"; >
{
	pass DefaultPass
	{		
		SetVertexShader( CompileShader( vs_5_0, VS_Main() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_Main() ) );
	}
}
