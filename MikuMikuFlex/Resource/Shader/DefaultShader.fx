

// Script �錾 ///////////////////////////////////////////


float Script : STANDARDSGLOBAL <
	string ScriptClass="object";
	string Script="";
> = 0.8;


// �O���[�o���ϐ� ///////////////////////////////////////////


float4x4 matWVP       : WORLDVIEWPROJECTION < string Object="Camera"; >;
float4x4 matWV        : WORLDVIEW < string Object = "Camera"; >;
float4x4 WorldMatrix  : WORLD;
float4x4 ViewMatrix   : VIEW;
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

cbuffer BasicMaterialConstant   // cbuffer �ɂ̓Z�}���e�B�b�N��t�����Ȃ��̂ŁA���O�ɂ���Ď��ʂ���A�A�v������f�[�^���������܂��B
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


// ����̓��o�͒�` ///////////////////////////////////////


// �R���s���[�g�V�F�[�_����

float4x4 BoneTrans[768] : BONETRANS;

struct CS_INPUT
{
    float4 Position;
    float4 BoneWeight;
    uint4  BoneIndex;
    float3 Normal;
    float2 Tex;
    float4 AddUV1;
    float4 AddUV2;
    float4 AddUV3;
    float4 AddUV4;
    float4 Sdef_C;
    float3 Sdef_R0;
    float3 Sdef_R1;
    float  EdgeWeight;
    uint   Index;
    uint   Deform;
};

StructuredBuffer<CS_INPUT> CSBuffer : register(t0);

#define DEFORM_BDEF1    0
#define DEFORM_BDEF2    1
#define DEFORM_BDEF4    2
#define DEFORM_SDEF     3
#define DEFORM_QDEF     4


// ���_�V�F�[�_����

struct VS_INPUT
{
	float4 Position   : POSITION;      // �X�L�j���O��̍��W�i���[�J�����W�j
	float3 Normal     : NORMAL;        // �@���i���[�J�����W�j
	float2 Tex        : TEXCOORD0;     // UV
	float4 AddUV1     : TEXCOORD1;     // �ǉ�UV1
	float4 AddUV2     : TEXCOORD2;     // �ǉ�UV2
	float4 AddUV3     : TEXCOORD3;     // �ǉ�UV3
	float4 AddUV4     : TEXCOORD4;     // �ǉ�UV4
	float  EdgeWeight : EDGEWEIGHT;    // �G�b�W�E�F�C�g
	uint   Index      : PSIZE15;       // ���_�C���f�b�N�X�l
};

#define VS_INPUT_SIZE  ((4+3+2+4+4+4+4+1+1)*4)

RWByteAddressBuffer VSBuffer : register(u0);


// ���_�V�F�[�_�o��

struct VS_OUTPUT
{
	float4 Position   : SV_POSITION;	// ���W�i�ˉe���W�j
	float3 Normal	  : NORMAL;			// �@��
	float2 Tex		  : TEXCOORD1;		// �e�N�X�`��
	float3 Eye		  : TEXCOORD3;		// �J�����Ƃ̑��Έʒu
	float2 SpTex	  : TEXCOORD4;		// �X�t�B�A�}�b�v�e�N�X�`�����W
	float4 Color	  : COLOR0;			// �f�B�t���[�Y�F
};


// �X�L�j���O /////////////////////////////////////////////////


void BDEF(CS_INPUT input, out float4 position, out float3 normal)
{
    float4x4 bt =
        BoneTrans[input.BoneIndex[0]] * input.BoneWeight[0] +
        BoneTrans[input.BoneIndex[1]] * input.BoneWeight[1] +
        BoneTrans[input.BoneIndex[2]] * input.BoneWeight[2] +
        BoneTrans[input.BoneIndex[3]] * input.BoneWeight[3];

    position = mul(input.Position, bt);
    normal = normalize(mul(float4(input.Normal, 0), bt)).xyz;
}

void SDEF(CS_INPUT input, out float4 position, out float3 normal)
{
    // TODO: SDEF �̎����ɕύX����B

    float4x4 bt =
        BoneTrans[input.BoneIndex[0]] * input.BoneWeight[0] +
        BoneTrans[input.BoneIndex[1]] * input.BoneWeight[1] +
        BoneTrans[input.BoneIndex[2]] * input.BoneWeight[2] +
        BoneTrans[input.BoneIndex[3]] * input.BoneWeight[3];

    position = mul(input.Position, bt);
    normal = normalize(mul(float4(input.Normal, 0), bt)).xyz;
}

void QDEF(CS_INPUT input, out float4 position, out float3 normal)
{
    // TODO: QDEF �̎����ɕύX����B

    float4x4 bt =
        BoneTrans[input.BoneIndex[0]] * input.BoneWeight[0] +
        BoneTrans[input.BoneIndex[1]] * input.BoneWeight[1] +
        BoneTrans[input.BoneIndex[2]] * input.BoneWeight[2] +
        BoneTrans[input.BoneIndex[3]] * input.BoneWeight[3];

    position = mul(input.Position, bt);
    normal = normalize(mul(float4(input.Normal, 0), bt)).xyz;
}


// �R���s���[�g�V�F�[�_�[
// �@X��������Ȃ��̂ŁADispach �� (���_��/64+1, 1, 1) �Ƃ��邱�ƁB
// �@��: ���_���� 130 �Ȃ� Dispach( 3, 1, 1 )

[numthreads(64,1,1)]
void CS_Skinning( uint3 id : SV_DispatchThreadID )
{
    uint csIndex = id.x;    // ���_�ԍ��i0�`���_��-1�j
    uint vsIndex = csIndex * VS_INPUT_SIZE;    // �o�͈ʒu[byte�P�ʁi�K��4�̔{���ł��邱�Ɓj]

    CS_INPUT input = CSBuffer[csIndex];


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

    VSBuffer.Store4(vsIndex + 0, asuint(position));
    VSBuffer.Store3(vsIndex + 16, asuint(normal));
    VSBuffer.Store2(vsIndex + 28, asuint(input.Tex));
    VSBuffer.Store4(vsIndex + 36, asuint(input.AddUV1));
    VSBuffer.Store4(vsIndex + 52, asuint(input.AddUV2));
    VSBuffer.Store4(vsIndex + 68, asuint(input.AddUV3));
    VSBuffer.Store4(vsIndex + 84, asuint(input.AddUV4));
    VSBuffer.Store(vsIndex + 100, asuint(input.EdgeWeight));
    VSBuffer.Store(vsIndex + 104, asuint(input.Index));
}

// �e�N�j�b�N�ƃp�X

technique11 DefaultSkinning < string MMDPass = "skinning"; >
{
    pass DefaultPass
    {
        SetComputeShader(CompileShader(cs_5_0, CS_Skinning()));
    }
}

// �I�u�W�F�N�g�`�� ///////////////////////////////////////////


// ���_�V�F�[�_

VS_OUTPUT VS_Object(VS_INPUT input)
{
    VS_OUTPUT Out = (VS_OUTPUT) 0;

	// �ʒu�i���[���h�r���[�ˉe�ϊ��j
	Out.Position = mul(input.Position, matWVP);

	// �J�����Ƃ̑��Έʒu
    Out.Eye = (ViewPointPosition - mul(input.Position, WorldMatrix)).xyz;

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
        float2 NormalWV = mul(float4(Out.Normal, 0), ViewMatrix).xy;
		Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
		Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	}
    else
    {
        Out.SpTex.x = 0.0f;
        Out.SpTex.y = 0.0f;
    }

	return Out;
}


// �s�N�Z���V�F�[�_

float4 PS_Object( VS_OUTPUT IN ) : SV_TARGET
{
    // ���ːF�v�Z
	
	float3 LightDirection = -normalize( mul( LightPointPosition, matWV ) ).xyz;
    float3 HalfVector = normalize(normalize(IN.Eye) - mul(float4(LightDirection, 0), matWV).xyz);
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

    float LightNormal = dot(IN.Normal, -mul(float4(LightDirection, 0), matWV).xyz);
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

technique11 DefaultObject < string MMDPass = "object"; >
{
    pass DefaultPass
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Object()));
        SetPixelShader(CompileShader(ps_5_0, PS_Object()));
    }
}


// �G�b�W�`�� ////////////////////////////////////////////////


// ���_�V�F�[�_

VS_OUTPUT VS_Edge(VS_INPUT IN)
{
    VS_OUTPUT Out = (VS_OUTPUT) 0;

	Out.Normal = normalize(mul(IN.Normal, (float3x3)WorldMatrix));	// ���_�@��

	// �ʒu�i���[�J�����W�j���A�@�������ɖc��܂��Ă���A���[���h�r���[�ˉe�ϊ�����B
	float4 position = IN.Position + float4(Out.Normal, 0) * EdgeWidth * IN.EdgeWeight * distance(IN.Position.xyz, CameraPosition) * 0.0005;
	Out.Position = mul(position, matWVP);

    Out.Eye = (ViewPointPosition - mul(IN.Position, WorldMatrix)).xyz; // �J�����Ƃ̑��Έʒu
	Out.Tex = IN.Tex;	// �e�N�X�`��

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
        SetBlendState(NoBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF); //AlphaBlendEnable = FALSE;
		//AlphaTestEnable = FALSE;	--> D3D10 �ȍ~�͔p�~

        SetVertexShader(CompileShader(vs_5_0, VS_Edge()));
        SetPixelShader(CompileShader(ps_5_0, PS_Edge()));
    }
}
