echo off
echo ------------------------------------------------------------
echo MikuMikuFlex �� NuGet �p�b�P�[�W (.nupkg) �쐬�o�b�`
echo ���O�� Release/x64  �̃r���h���������Ă������ƁB
echo �܂��ANuGet�p�b�P�[�W�̑����i�o�[�W�����Ȃǁj���ς������A
echo MikuMikuFlex3/MikuMikuFlex.nuspec ���C�����邱�ƁB
echo ------------------------------------------------------------

nuget pack ..\MikuMikuFlex3\MikuMikuFlex3.csproj -IncludeReferencedProjects -properties Configuration=Release;Platform=x64 -OutputDirectory nuget_packages
pause
