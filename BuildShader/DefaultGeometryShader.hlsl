////////////////////////////////////////////////////////////////////////////////////////////////////
//
// �W�I���g���V�F�[�_�[
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#include "DefaultVS_OUTPUT.hlsli"
#include "GlobalParameters.hlsli"

[maxvertexcount(3)]
void main(
	triangle VS_OUTPUT input[3],
	inout TriangleStream<VS_OUTPUT> output
)
{
    for (uint i = 0; i < 3; i++)
    {
        VS_OUTPUT element = input[i];
        output.Append(element);
    }
}
