using System.Collections.Generic;
using System.Drawing;
using MikuMikuFlex.DeviceManagement;
using MikuMikuFlex.Utility;
using SharpDX;
using SharpDX.Direct3D11;
using SharpDX.DXGI;

namespace MikuMikuFlex.���f��.Shape
{
	public abstract class �V�F�C�v : IDrawable, HitTestable
	{
        public bool �\���� { get; set; }

        public abstract string �t�@�C���� { get; }

        public int �T�u�Z�b�g�� { get; private set; }

        public abstract int ���_�� { get; }

        public ���f����� ���f����� { get; private set; }

        public Vector4 �Z���t�V���h�E�F { get; set; }

        public Vector4 �n�ʉe�F { get; set; }


        public �V�F�C�v( Vector4 �F )
		{
			_color = �F;
            �\���� = true;
			�T�u�Z�b�g�� = 1;
			���f����� = new Transformer��{����();
		}

		public void ����������()
		{
            // �V�F�C�v�V�F�[�_�[���쐬����B

            _D3DEffect = CGHelper.EffectFx5���쐬����FromResource( @"MMF.Resource.Shader.ShapeShader.fx", RenderContext.Instance.DeviceManager.D3DDevice );


            // ���_���X�g���쐬���A��������Ƃɒ��_�o�b�t�@���쐬����B

			var ���_���X�g = new List<Vector4>();
			InitializePositions( ���_���X�g );
			_D3D���_�o�b�t�@ = CGHelper.D3D�o�b�t�@���쐬����( ���_���X�g, RenderContext.Instance.DeviceManager.D3DDevice, BindFlags.VertexBuffer );


            // �C���f�b�N�X�o�b�t�@���쐬����B

            var builder = new �C���f�b�N�X�o�b�t�@Builder();
			InitializeIndex( builder );
            _D3D�C���f�b�N�X�o�b�t�@ = builder.�C���f�b�N�X�o�b�t�@���쐬����();


            // ���̓��C�A�E�g���쐬����B

            _D3D���̓��C�A�E�g = new InputLayout(
                RenderContext.Instance.DeviceManager.D3DDevice, 
                _D3DEffect.GetTechniqueByIndex( 0 ).GetPassByIndex( 0 ).Description.Signature,
                �V�F�C�v�p���̓G�������g.VertexElements );
		}

        public void Dispose()
        {
            _D3D�C���f�b�N�X�o�b�t�@?.Dispose();
            _D3D�C���f�b�N�X�o�b�t�@ = null;

            _D3D���_�o�b�t�@?.Dispose();
            _D3D���_�o�b�t�@ = null;

            _D3DEffect?.Dispose();
            _D3DEffect = null;

            _D3D���̓��C�A�E�g?.Dispose();
            _D3D���̓��C�A�E�g = null;
        }

		public void �`�悷��()
		{
			var d3dContext = RenderContext.Instance.DeviceManager.D3DDevice.ImmediateContext;

            // �G�t�F�N�g�̕ϐ��̐ݒ�
			_D3DEffect.GetVariableBySemantic( "COLOR" ).AsVector().Set( _color );
            _D3DEffect.GetVariableBySemantic( "WORLDVIEWPROJECTION" ).AsMatrix().SetMatrix( RenderContext.Instance.�s��Ǘ�.���[���h�r���[�ˉe�s����쐬����( this ) );

            // ���̓A�Z���u���̐ݒ�
            d3dContext.InputAssembler.PrimitiveTopology = SharpDX.Direct3D.PrimitiveTopology.TriangleList;
            d3dContext.InputAssembler.InputLayout = _D3D���̓��C�A�E�g;
			d3dContext.InputAssembler.SetIndexBuffer( _D3D�C���f�b�N�X�o�b�t�@, Format.R32_UInt, 0 );
			d3dContext.InputAssembler.SetVertexBuffers( 0, new VertexBufferBinding( _D3D���_�o�b�t�@, �V�F�C�v�p���̓G�������g.SizeInBytes, 0 ) );

            // �G�t�F�N�g�̃e�N�j�b�N��K�p
            _D3DEffect.GetTechniqueByIndex( 0 ).GetPassByIndex( 0 ).Apply( d3dContext );

            // �V�F�C�v��`��
            d3dContext.DrawIndexed( ���_��, 0, 0 );
		}

		public void �X�V����()
		{

		}

		public void RenderHitTestBuffer( float �F )
		{
			var d3dContext = RenderContext.Instance.DeviceManager.D3DDevice.ImmediateContext;

			d3dContext.InputAssembler.PrimitiveTopology = SharpDX.Direct3D.PrimitiveTopology.TriangleList;

			_D3DEffect.GetVariableBySemantic( "COLOR" ).AsVector().Set( new Vector4( �F, 0, 0, 0 ) );
            _D3DEffect.GetVariableBySemantic( "WORLDVIEWPROJECTION" ).AsMatrix().SetMatrix( RenderContext.Instance.�s��Ǘ�.���[���h�r���[�ˉe�s����쐬����( this ) );

			d3dContext.InputAssembler.InputLayout = _D3D���̓��C�A�E�g;
			d3dContext.InputAssembler.SetIndexBuffer( _D3D�C���f�b�N�X�o�b�t�@, Format.R32_UInt, 0 );
			d3dContext.InputAssembler.SetVertexBuffers( 0, new VertexBufferBinding( _D3D���_�o�b�t�@, �V�F�C�v�p���̓G�������g.SizeInBytes, 0 ) );

            _D3DEffect.GetTechniqueByIndex( 0 ).GetPassByIndex( 1 ).Apply( d3dContext );

            d3dContext.DrawIndexed( ���_��, 0, 0 );
		}

		public virtual void HitTestResult( bool result, bool mouseState, System.Drawing.Point mousePosition )
		{
		}


        protected Vector4 _color;

        protected abstract void InitializeIndex( �C���f�b�N�X�o�b�t�@Builder builder );

        protected abstract void InitializePositions( List<Vector4> positions );


        private InputLayout _D3D���̓��C�A�E�g;

        private Effect _D3DEffect;

        private Buffer _D3D�C���f�b�N�X�o�b�t�@;

        private Buffer _D3D���_�o�b�t�@;
    }
}