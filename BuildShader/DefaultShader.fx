
// �N�H�[�^�j�I�� /////////////////////////////////////////

#define QUATERNION_IDENTITY float4(0, 0, 0, 1)

float4 q_slerp(float4 a, float4 b, float t)
{
    // if either input is zero, return the other.
    if (length(a) == 0.0)
    {
        if (length(b) == 0.0)
        {
            return QUATERNION_IDENTITY;
        }
        return b;
    }
    else if (length(b) == 0.0)
    {
        return a;
    }

    float cosHalfAngle = a.w * b.w + dot(a.xyz, b.xyz);

    if (cosHalfAngle >= 1.0 || cosHalfAngle <= -1.0)
    {
        return a;
    }
    else if (cosHalfAngle < 0.0)
    {
        b.xyz = -b.xyz;
        b.w = -b.w;
        cosHalfAngle = -cosHalfAngle;
    }

    float blendA;
    float blendB;
    if (cosHalfAngle < 0.99)
    {
        // do proper slerp for big angles
        float halfAngle = acos(cosHalfAngle);
        float sinHalfAngle = sin(halfAngle);
        float oneOverSinHalfAngle = 1.0 / sinHalfAngle;
        blendA = sin(halfAngle * (1.0 - t)) * oneOverSinHalfAngle;
        blendB = sin(halfAngle * t) * oneOverSinHalfAngle;
    }
    else
    {
        // do lerp if angle is really small.
        blendA = 1.0 - t;
        blendB = t;
    }

    float4 result = float4(blendA * a.xyz + blendB * b.xyz, blendA * a.w + blendB * b.w);
    if (length(result) > 0.0)
    {
        return normalize(result);
    }
    return QUATERNION_IDENTITY;
}

float4x4 quaternion_to_matrix(float4 quat)
{
    float4x4 m = float4x4(float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0));

    float x = quat.x, y = quat.y, z = quat.z, w = quat.w;
    float x2 = x + x, y2 = y + y, z2 = z + z;
    float xx = x * x2, xy = x * y2, xz = x * z2;
    float yy = y * y2, yz = y * z2, zz = z * z2;
    float wx = w * x2, wy = w * y2, wz = w * z2;

    m[0][0] = 1.0 - (yy + zz);
    m[0][1] = xy - wz;
    m[0][2] = xz + wy;

    m[1][0] = xy + wz;
    m[1][1] = 1.0 - (xx + zz);
    m[1][2] = yz - wx;

    m[2][0] = xz - wy;
    m[2][1] = yz + wx;
    m[2][2] = 1.0 - (xx + yy);

    m[3][3] = 1.0;

    return m;
}


// Script �錾 ///////////////////////////////////////////


float Script : STANDARDSGLOBAL <
	string ScriptClass="object";
	string Script="";
> = 0.8;


// �O���[�o���ϐ� ///////////////////////////////////////////


float4 EdgeColor : EDGECOLOR; // �G�b�W�̐F 
float  EdgeWidth : EDGEWIDTH; // �G�b�W�̕�

float4x4 matWVP         : WORLDVIEWPROJECTION < string Object="Camera"; >;
float4x4 matWV          : WORLDVIEW < string Object = "Camera"; >;
float4x4 WorldMatrix    : WORLD;
float4x4 ViewMatrix     : VIEW;
float4x4 ViewProjMatrix : VIEWPROJECTION;

float2   viewportSize       : VIEWPORTPIXELSIZE;
float4   ViewPointPosition  : POSITION < string object="camera"; >;	// �J�����ʒu�ifloat4�j
float4   LightPointPosition : POSITION < string object="light"; >;	// �����ʒu
float3	 CameraPosition		: POSITION < string object = "camera"; > ;	// �J�����ʒu�ifloat3�j

Texture2D Texture       : MATERIALTEXTURE;		// �T���v�����O�p�e�N�X�`��
Texture2D SphereTexture : MATERIALSPHEREMAP;	// �T���v�����O�p�X�t�B�A�}�b�v�e�N�X�`��
Texture2D Toon          : MATERIALTOONTEXTURE;  // �T���v�����O�p�g�D�[���e�N�X�`��


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

#define MAX_BONE    768

cbuffer BoneTransBuffer
{
    float4x4 BoneTrans[MAX_BONE]; // �{�[���̃��f���|�[�Y�̔z��
}
cbuffer BoneLocalPositionBuffer
{
    float3 BoneLocalPosition[MAX_BONE]; // �{�[���̃��[�J���ʒu�̔z��iSDEF�Ŏg�p�j
}
cbuffer BoneQuaternionBuffer
{
    float4 BoneQuaternion[MAX_BONE]; // �{�[���̉�]�i�N�H�[�^�j�I���j�̔z��iSDEF�Ŏg�p�j
}

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
    normal = normalize(mul(input.Normal, (float3x3) bt));
}

void SDEF(CS_INPUT input, out float4 position, out float3 normal)
{
    // �Q�l: 
    // �����p�����uPMX�̃X�t�B���J���f�t�H�[���̃R�[�h���ۂ����́v�isma42���j
    // https://www.pixiv.net/member_illust.php?mode=medium&illust_id=60755964

    float w0 = 0.0f; // �Œ�l�ł���SDEF�p�����[�^�ɂ݈̂ˑ�����̂ŁA�����̒l���Œ�l�B
    float w1 = 0.0f; //

    float L0 = length(input.Sdef_R0 - (float3) BoneLocalPosition[input.BoneIndex[1]]); // �q�{�[������R0�܂ł̋���
    float L1 = length(input.Sdef_R1 - (float3) BoneLocalPosition[input.BoneIndex[1]]); // �q�{�[������R1�܂ł̋���

    if (abs(L0 - L1) < 0.0001f)
    {
        w0 = 0.5f;
    }
    else
    {
        w0 = saturate(L0 / (L0 + L1));
    }
    w1 = 1.0f - w0;

    float4x4 modelPoseL = BoneTrans[input.BoneIndex[0]] * input.BoneWeight[0];
    float4x4 modelPoseR = BoneTrans[input.BoneIndex[1]] * input.BoneWeight[1];
    float4x4 modelPoseC = modelPoseL + modelPoseR;

    float4 Cpos = mul(input.Sdef_C, modelPoseC);   // BDEF2�Ōv�Z���ꂽ�_C�̈ʒu
    float4 Ppos = mul(input.Position, modelPoseC); // BDEF2�Ōv�Z���ꂽ���_�̈ʒu

    float4 qp = q_slerp(
        BoneQuaternion[input.BoneWeight[0]] * input.BoneWeight[0],
        BoneQuaternion[input.BoneWeight[1]] * input.BoneWeight[1],
        input.BoneWeight[0]);
    float4x4 qpm = quaternion_to_matrix(qp);

    float4 R0pos = mul(float4(input.Sdef_R0, 1.0f), (modelPoseL + (modelPoseC * -input.BoneWeight[0])));
    float4 R1pos = mul(float4(input.Sdef_R1, 1.0f), (modelPoseR + (modelPoseC * -input.BoneWeight[1])));
    Cpos += (R0pos * w0) + (R1pos * w1); // �c��݂����h�~�H

    Ppos -= Cpos;          // ���_��_C�����S�ɂȂ�悤�ړ�����
    Ppos = mul(Ppos, qpm); // ��]����
    Ppos += Cpos;          // ���̈ʒu��

    position = Ppos;
    normal = normalize(mul(float4(input.Normal, 0), qpm)).xyz;
}

void QDEF(CS_INPUT input, out float4 position, out float3 normal)
{
    // TODO: QDEF �̎����ɕύX����B�i���܂�BDEF4�Ɠ����j

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
    uint csIndex = id.x; // ���_�ԍ��i0�`���_��-1�j
    uint vsIndex = csIndex * VS_INPUT_SIZE; // �o�͈ʒu[byte�P�ʁi�K��4�̔{���ł��邱�Ɓj]

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

VS_OUTPUT VS_Object(VS_INPUT input, uniform bool bEdge)
{
    VS_OUTPUT Out = (VS_OUTPUT) 0;

	// ���_�@��
    Out.Normal = normalize(mul(input.Normal, (float3x3) WorldMatrix));

	// �ʒu
    float4 position = input.Position;
    if( bEdge )
    {
        // �G�b�W�Ȃ�@�������ɖc��܂���B
        position = input.Position + float4(Out.Normal, 0) * EdgeWidth * input.EdgeWeight * distance(input.Position.xyz, CameraPosition) * 0.0005;
    }
    Out.Position = mul(position, WorldMatrix);  // ���[���h�ϊ�

	// �J�����Ƃ̑��Έʒu
    Out.Eye = (ViewPointPosition - mul(input.Position, WorldMatrix)).xyz;

	// �f�B�t���[�Y�F�v�Z
    Out.Color.rgb = DiffuseColor.rgb;
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate(Out.Color); // 0�`1 �Ɋۂ߂�

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


// �n���V�F�[�_
//   �Q�l1�FCurved PN Triangles  http://alex.vlachos.com/graphics/CurvedPNTriangles.pdf
//   �Q�l2�FSimpleBezier11 �T���v��(MSDN) https://msdn.microsoft.com/ja-jp/library/ee416574(v=vs.85).aspx

float TessFactor : TESSFACTOR; // �e�b�Z���[�V�����W��

struct CONSTANT_HS_OUT
{
    float Edges[3] : SV_TessFactor; // �p�b�`�̃G�b�W�̃e�b�Z���[�V�����W��
    float Inside : SV_InsideTessFactor; // �p�b�`�����̃e�b�Z���[�V�����W��
    float3 B210 : POSITION3;
    float3 B120 : POSITION4;
    float3 B021 : POSITION5;
    float3 B012 : POSITION6;
    float3 B102 : POSITION7;
    float3 B201 : POSITION8;
    float3 B111 : CENTER;
    float3 N110 : NORMAL3;
    float3 N011 : NORMAL4;
    float3 N101 : NORMAL5;
};

CONSTANT_HS_OUT ConstantsHS_Object(InputPatch<VS_OUTPUT, 3> ip, uint PatchID : SV_PrimitiveID)
{
    CONSTANT_HS_OUT Out;

    // �萔�o�b�t�@�̒l�����̂܂ܓn��
    Out.Edges[0] = Out.Edges[1] = Out.Edges[2] = TessFactor; // �p�b�`�̃G�b�W�̃e�b�Z���[�V�����W��
    Out.Inside = (Out.Edges[0] + Out.Edges[1] + Out.Edges[2]) / 3.0f; // �p�b�`�����̃e�b�Z���[�V�����W��

    // �R���g���[�� �|�C���g��ǉ�

    float3 B003 = ip[2].Position.xyz;
    float3 B030 = ip[1].Position.xyz;
    float3 B300 = ip[0].Position.xyz;
    float3 N002 = ip[2].Normal;
    float3 N020 = ip[1].Normal;
    float3 N200 = ip[0].Normal;

    Out.B210 = ((2.0f * B003) + B030 - (dot((B030 - B003), N002) * N002)) / 3.0f;
    Out.B120 = ((2.0f * B030) + B003 - (dot((B003 - B030), N020) * N020)) / 3.0f;
    Out.B021 = ((2.0f * B030) + B300 - (dot((B300 - B030), N020) * N020)) / 3.0f;
    Out.B012 = ((2.0f * B300) + B030 - (dot((B030 - B300), N200) * N200)) / 3.0f;
    Out.B102 = ((2.0f * B300) + B003 - (dot((B003 - B300), N200) * N200)) / 3.0f;
    Out.B201 = ((2.0f * B003) + B300 - (dot((B300 - B003), N002) * N002)) / 3.0f;
    float3 E = (Out.B210 + Out.B120 + Out.B021 + Out.B012 + Out.B102 + Out.B201) / 6.0f;
    float3 V = (B003 + B030 + B300) / 3.0f;
    Out.B111 = E + ((E - V) / 2.0f);

    float V12 = 2.0f * dot(B030 - B003, N002 + N020) / dot(B030 - B003, B030 - B003);
    Out.N110 = normalize(N002 + N020 - V12 * (B030 - B003));
    float V23 = 2.0f * dot(B300 - B030, N020 + N200) / dot(B300 - B030, B300 - B030);
    Out.N011 = normalize(N020 + N200 - V23 * (B300 - B030));
    float V31 = 2.0f * dot(B003 - B300, N200 + N002) / dot(B003 - B300, B003 - B300);
    Out.N101 = normalize(N200 + N002 - V31 * (B003 - B300));

    return Out;
}

[domain("tri")]
[partitioning("integer")]
[outputtopology("triangle_ccw")]
[outputcontrolpoints(3)]
[patchconstantfunc("ConstantsHS_Object")]
VS_OUTPUT HS_Object(InputPatch<VS_OUTPUT, 3> In, uint i : SV_OutputControlPointID, uint PatchID : SV_PrimitiveID)
{
    VS_OUTPUT output = (VS_OUTPUT) 0;

    output.Position = In[i].Position;
    output.Normal = In[i].Normal;
    output.Tex = In[i].Tex;
    output.Eye = In[i].Eye;
    output.SpTex = In[i].SpTex;
    output.Color = In[i].Color;

    return output;
}


// �h���C���V�F�[�_

[domain("tri")]
VS_OUTPUT DS_Object(CONSTANT_HS_OUT In, float3 uvw : SV_DomainLocation, const OutputPatch<VS_OUTPUT, 3> patch)
{
    VS_OUTPUT Out = (VS_OUTPUT) 0;

    float U = uvw.x;
    float V = uvw.y;
    float W = uvw.z;
    float UU = U * U;
    float VV = V * V;
    float WW = W * W;
    float UUU = UU * U;
    float VVV = VV * V;
    float WWW = WW * W;

    // ���_���W
    float3 Position = patch[2].Position.xyz * WWW +
                      patch[1].Position.xyz * UUU +
                      patch[0].Position.xyz * VVV +
                      In.B210 * WW * 3 * U +
                      In.B120 * W * UU * 3 +
                      In.B201 * WW * 3 * V +
                      In.B021 * UU * 3 * V +
                      In.B102 * W * VV * 3 +
                      In.B012 * U * VV * 3 +
                      In.B111 * 6 * W * U * V;
    Out.Position = mul(float4(Position, 1), ViewProjMatrix); //�r���[�ˉe�ϊ�

    // �J�����Ƃ̑��Έʒu
    Out.Eye = ViewPointPosition.xyz - Position;

    // �@���x�N�g��
    float3 Normal = patch[2].Normal * WW +
                    patch[1].Normal * UU +
                    patch[0].Normal * VV +
                    In.N110 * W * U +
                    In.N011 * U * V +
                    In.N101 * W * V;
    Out.Normal = normalize(Normal);

    // �e�N�X�`�����W
    Out.Tex = patch[2].Tex * W + patch[1].Tex * U + patch[0].Tex * V;
  
    // ���̑�
    Out.SpTex = patch[2].SpTex * W + patch[1].SpTex * U + patch[0].SpTex * V;
    Out.Color = patch[2].Color * W + patch[1].Color * U + patch[0].Color * V;

    return Out;
}


// �s�N�Z���V�F�[�_

float4 PS_Object( VS_OUTPUT IN ) : SV_TARGET
{
    // ���ːF�v�Z
	
    float3 LightDirection = -normalize(mul(LightPointPosition, matWV)).xyz;
    float3 HalfVector = normalize(normalize(IN.Eye) - mul(float4(LightDirection, 0), matWV).xyz);
    float3 Specular = pow(max(0.00001, dot(HalfVector, normalize(IN.Normal))), SpecularPower) * SpecularColor.rgb;
    float4 Color = IN.Color;


	// �e�N�X�`���T���v�����O

    if (use_texture)
    {
        Color *= Texture.Sample(mySampler, IN.Tex);
    }

	// �X�t�B�A�}�b�v�T���v�����O

    if (use_spheremap)
    {
        if (spadd)
        {
            Color.rgb += SphereTexture.Sample(mySampler, IN.SpTex).rgb; // ���Z
        }
        else
        {
            Color.rgb *= SphereTexture.Sample(mySampler, IN.SpTex).rgb; // ��Z
        }
    }

	
	// �V�F�[�f�B���O

    //float LightNormal = dot(IN.Normal, -mul(float4(LightDirection, 0), matWV).xyz);
    float LightNormal = dot(IN.Normal, -LightDirection.xyz);
    float shading = saturate(LightNormal); // 0�`1 �Ɋۂ߂�

	
	// �g�D�[���e�N�X�`���T���v�����O
	
    if (use_toontexturemap)
    {
        float3 MaterialToon = Toon.Sample(mySampler, float2(0, shading)).rgb;
        Color.rgb *= MaterialToon;
    }
    else
    {
        //float3 MaterialToon = 1.0f.xxx * shading;
        float3 MaterialToon = 1.0f.xxx * (0.85f + shading * 0.15f); // shading:0��1 �̂Ƃ��AMaerialToon: 0.85��1.0
        Color.rgb *= MaterialToon;
    }
    
    
    // �F�ɔ��ˌ������Z

    Color.rgb += Specular;

	
	// �F�Ɋ��������Z

	//Color.rgb += AmbientColor.rgb * 0.2;	//TODO MMD��Ambient�̌W�����킩���E�E�E
    Color.rgb += AmbientColor.rgb * 0.005;

    return Color;
}


// �e�N�j�b�N�ƃp�X

technique11 DefaultObject < string MMDPass = "object"; >
{
    pass DefaultPass
    {
        SetDepthStencilState(NULL, 0);
        SetVertexShader(CompileShader(vs_5_0, VS_Object(false)));
        SetHullShader(CompileShader(hs_5_0, HS_Object()));
        SetDomainShader(CompileShader(ds_5_0, DS_Object()));
        SetPixelShader(CompileShader(ps_5_0, PS_Object()));
    }
}


// �G�b�W�`�� ////////////////////////////////////////////////


// �s�N�Z���V�F�[�_

float4 PS_Edge( VS_OUTPUT IN ) : SV_TARGET
{
    return EdgeColor;
}


// �e�N�j�b�N�ƃp�X

technique11 DefaultEdge < string MMDPass = "edge"; >
{
    pass DefaultPass
    {
        SetDepthStencilState(NULL, 0);
        SetVertexShader(CompileShader(vs_5_0, VS_Object(true)));
        SetHullShader(CompileShader(hs_5_0, HS_Object()));
        SetDomainShader(CompileShader(ds_5_0, DS_Object()));
        SetPixelShader(CompileShader(ps_5_0, PS_Edge()));
    }
}
