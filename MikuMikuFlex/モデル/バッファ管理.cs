using System;

namespace MikuMikuFlex.���f��
{
	public interface �o�b�t�@�Ǘ� : IDisposable
	{
        SharpDX.Direct3D11.Buffer D3D���_�o�b�t�@ { get; }

        SharpDX.Direct3D11.Buffer D3D�C���f�b�N�X�o�b�t�@ { get; }

		CS_INPUT[] ���͒��_���X�g { get; }

        SharpDX.Direct3D11.InputLayout D3D���_���C�A�E�g { get; }

        /// <summary>
        ///     ���_���[�t�Ȃǂɂ�蒸�_�f�[�^���ύX���ꂽ�ꍇ�� true �ɂ���B
        ///     ����ƁA����̍X�V���� <see cref="D3D�X�L�j���O�o�b�t�@���X�V����"/> ���ǂ݂������B
        /// </summary>
        bool D3D�X�L�j���O�o�b�t�@�����Z�b�g���� { get; set; }


        void ����������( object model, SharpDX.Direct3D11.Effect d3dEffect );

        void D3D�X�L�j���O�o�b�t�@���X�V����( �X�L�j���O skelton, �G�t�F�N�g effect );
    }
}
