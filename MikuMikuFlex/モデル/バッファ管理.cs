using System;

namespace MMF.���f��
{
	public interface �o�b�t�@�Ǘ� : IDisposable
	{
        SharpDX.Direct3D11.Buffer D3D���_�o�b�t�@ { get; }

        SharpDX.Direct3D11.Buffer D3D�C���f�b�N�X�o�b�t�@ { get; }

		MMM_SKINNING_INPUT[] ���͒��_���X�g { get; }

        SharpDX.Direct3D11.InputLayout D3D���_���C�A�E�g { get; }

        int ���_�� { get; }

        /// <summary>
        ///     ���_���[�t�Ȃǂɂ�蒸�_�f�[�^���ύX���ꂽ�ꍇ�� true �ɂ���B
        ///     ����ƁA����̍X�V���� <see cref="�K�v�ł���Β��_���č쐬����"/> ���ǂ݂������B
        /// </summary>
        bool ���Z�b�g���K�v�ł��� { get; set; }


        void ����������( object model, SharpDX.Direct3D11.Effect d3dEffect );

        void �K�v�ł���Β��_���č쐬����();
    }
}
