echo off
echo ------------------------------------------------------------
echo MikuMikuFlex �� NuGet �p�b�P�[�W (.nupkg) �쐬�o�b�`
echo ���O�� AnyCPU/Release  �̃r���h���������Ă������ƁB(x64���r���h�ł��邪�ANuGet�ɂ�AnyCPU(=x86)�̂݌��J����B�j
echo �܂��ANuGet�p�b�P�[�W�̑����i�o�[�W�����Ȃǁj���ς������A
echo MikuMikuFlex/MikuMikuFlex.nuspec ���C�����邱�ƁB
echo ------------------------------------------------------------

nuget pack ..\MikuMikuFlex\MikuMikuFlex.csproj -IncludeReferencedProjects -properties Configuration=Release -OutputDirectory nuget_packages

echo ------------------------------------------------------------
echo ���ӁF
echo sharpdx_direct3d11_1_effects_[x68/x64].dll �ɑ΂���x�� NU5100 ���o���ꍇ��*����*���Ă��������B
echo SharpDX.Direct3D11.Effects �p�b�P�[�W�̍\��������Ȃ��߁A���̑΍�ł��B
echo ------------------------------------------------------------

pause