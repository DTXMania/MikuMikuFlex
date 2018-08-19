
/////////////////////////////////////////////
// Script �錾

float Script : STANDARDSGLOBAL <
	string ScriptClass="scene";
	string Script="";
> = 0.8;


/////////////////////////////////////////////
// �O���[�o���ϐ�

float4x4 matWVP : WORLDVIEWPROJECTION < string Object="Camera"; >;
float4x4 matWV:WORLDVIEW < string Object = "Camera"; >;
float4x4 WorldMatrix : WORLD;
float4x4 ViewMatrix : VIEW;
float2   viewportSize : VIEWPORTPIXELSIZE;
float4   ViewPointPosition : POSITION < string object="camera"; >;	// �J�����ʒu�ifloat4�j
float4   LightPointPosition : POSITION < string object="light"; >;	// �����ʒu
float3	 CameraPosition		: POSITION < string Object = "Camera"; > ;	// �J�����ʒu�ifloat3�j

Texture2D Texture : MATERIALTEXTURE;			// �T���v�����O�p�e�N�X�`��
Texture2D SphereTexture : MATERIALSPHEREMAP;	// �T���v�����O�p�X�t�B�A�}�b�v�e�N�X�`��
Texture2D Toon : MATERIALTOONTEXTURE;			// �T���v�����O�p�g�D�[���e�N�X�`��

float4 EdgeColor : EDGECOLOR;	// �G�b�W�̐F
float  EdgeWidth : EDGEWIDTH;	// �G�b�W�̕�


// �O���[�o���ϐ��G����p�����[�^

bool use_spheremap;			// �`�撆�̍ގ����X�t�B�A�}�b�v���g�p����Ȃ� true
bool spadd;					// �X�t�B�A�}�b�v���g���ꍇ�̃I�v�V�����B�itrue: ���Z�X�t�B�A�Afalse: ��Z�X�t�B�A�j
bool use_texture;			// �`�撆�̍ގ����e�N�X�`�����g�p����Ȃ� true
bool use_toontexturemap;	// �`�撆�̍ގ����g�D�[���e�N�X�`�����g�p����Ȃ� true
bool use_selfshadow;		// �`�撆�̍ގ����Z���t�e���g�p����Ȃ� true


// �萔�o�b�t�@�G�ގ��P�ʂŕς��Ȃ�����

cbuffer BasicMaterialConstant
{
	float4 AmbientColor:packoffset(c0);
	float4 DiffuseColor:packoffset(c1);
	float4 SpecularColor:packoffset(c2);
	float SpecularPower:packoffset(c3);
}


// �T���v���[�X�e�[�g; �e�N�X�`���A�X�t�B�A�}�b�v�A�g�D�[���e�N�X�`���ŋ���
SamplerState mySampler
{
   Filter = MIN_MAG_LINEAR_MIP_POINT;
   AddressU = WRAP;
   AddressV = WRAP;
};


/////////////////////////////////////////////
// ���o�͒�`


// ���_�V�F�[�_����
struct SKINNING_OUTPUT
{
	float4 Position   : POSITION;      // �X�L�j���O��̍��W�i���[�J�����W�j
	float3 Normal     : NORMAL;        // �@���i���[�J�����W�j
	float2 Tex        : TEXCOORD0;     // UV
	float4 AddUV1     : TEXCOORD1;     // �ǉ�UV1
	float4 AddUV2     : TEXCOORD2;     // �ǉ�UV2
	float4 AddUV3     : TEXCOORD3;     // �ǉ�UV3
	float4 AddUV4     : TEXCOORD4;     // �ǉ�UV4
	float  EdgeWeight : EDGEWEIGHT;    // �G�b�W�E�F�C�g
	float  Index      : PSIZE15;       // ���_�C���f�b�N�X�l
};

// ���_�V�F�[�_�o�́i���s�N�Z���V�F�[�_���́j
struct VS_OUTPUT
{
	float4 Position   : SV_POSITION;	// ���W�i�ˉe���W�j
	float3 Normal	  : NORMAL;			// �@��
	float2 Tex		  : TEXCOORD1;		// �e�N�X�`��
	float3 Eye		  : TEXCOORD3;		// �J�����Ƃ̑��Έʒu
	float2 SpTex	  : TEXCOORD4;		// �X�t�B�A�}�b�v�e�N�X�`�����W
	float4 Color	  : COLOR0;			// �f�B�t���[�Y�F
};


/////////////////////////////////////////////
// �I�u�W�F�N�g�`��p�V�F�[�_


// ���_�V�F�[�_

VS_OUTPUT VS_Main(SKINNING_OUTPUT input)
{
	VS_OUTPUT Out;

	// �ʒu�i���[���h�r���[�ˉe�ϊ��j
	Out.Position = mul(input.Position, matWVP);

	// �J�����Ƃ̑��Έʒu
	Out.Eye = ViewPointPosition - mul(input.Position, WorldMatrix);

	// ���_�@��
	Out.Normal = normalize(mul(input.Normal, (float3x3)WorldMatrix));

	// �f�B�t���[�Y�F�v�Z
	Out.Color.rgb = DiffuseColor.rgb;
	Out.Color.a = DiffuseColor.a;
	Out.Color = saturate(Out.Color);	// 0�`1 �Ɋۂ߂�

	Out.Tex = input.Tex;

	if (use_spheremap)
	{
		// �X�t�B�A�}�b�v�e�N�X�`�����W
		float2 NormalWV = mul(Out.Normal, (float3x3)ViewMatrix);
		Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
		Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	}

	return Out;
}


// �s�N�Z���V�F�[�_

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
	
	if ( use_toontexturemap )
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


// �e�N�j�b�N�ƃp�X

technique11 DefaultTechnique < string MMDPass = "object"; >
{
	pass DefaultPass
	{
		SetVertexShader(CompileShader(vs_5_0, VS_Main()));
		SetPixelShader(CompileShader(ps_5_0, PS_Main()));
	}
}


/////////////////////////////////////////////
// �G�b�W�`��p�V�F�[�_


// ���_�V�F�[�_

VS_OUTPUT VS_Edge(SKINNING_OUTPUT IN)
{
	VS_OUTPUT Out;

	Out.Position = IN.Position;	// �ʒu�i���[�J�����W�j
	Out.Eye = ViewPointPosition - mul(IN.Position, WorldMatrix);	// �J�����Ƃ̑��Έʒu
	Out.Normal = normalize(mul(IN.Normal, (float3x3)WorldMatrix));	// ���_�@��
	Out.Tex = IN.Tex;	// �e�N�X�`��

	// ���_��@�������ɖc��܂���
	float4 position = Out.Position + float4(Out.Normal, 0) * EdgeWidth * IN.EdgeWeight * distance(Out.Position.xyz, CameraPosition) * 0.0005;

	// ���[���h�r���[�ˉe�ϊ�
	Out.Position = mul(position, matWVP);

	return Out;
}


// �s�N�Z���V�F�[�_

float4 PS_Edge( VS_OUTPUT IN ) : SV_Target
{
	return EdgeColor;
}


// �e�N�j�b�N�ƃp�X

BlendState NoBlend
{
	BlendEnable[0] = False;
};
technique11 DefaultEdge < string MMDPass = "edge"; >
{
	pass DefaultPass
	{
		SetBlendState( NoBlend, float4(0.0f,0.0f,0.0f,0.0f), 0xFFFFFFFF );	//AlphaBlendEnable = FALSE;
		//AlphaTestEnable = FALSE;	--> D3D10 �ȍ~�͔p�~

		SetVertexShader( CompileShader( vs_5_0, VS_Edge() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_Edge() ) );
	}
}
