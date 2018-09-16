using System;
using System.Collections.Generic;
using SharpDX;

namespace MikuMikuFlex.���f��.Shape
{
	public class �V�����_�[�V�F�C�v : �V�F�C�v
	{
        public class SilinderShapeDescription
        {
            public float Thickness { get; }

            public uint DivideCount { get; }

            public SilinderShapeDescription( float thickness, uint divideCount )
            {
                this.Thickness = thickness;
                this.DivideCount = divideCount;
            }
        }


        public override string �t�@�C���� => "@@@SilinderShape@@@";

        public override int ���_�� => (int) ( _desc.DivideCount * 6 * 4 );


        public �V�����_�[�V�F�C�v( Vector4 color, SilinderShapeDescription desc ) 
            : base( color )
		{
			_desc = desc;
		}

		protected override void InitializeIndex( �C���f�b�N�X�o�b�t�@Builder builder )
		{
			uint n = _desc.DivideCount + 1;

            // ��̃����O
            for( uint i = 0; i < _desc.DivideCount; i++ )
				builder.�l�p�`��ǉ�����( i, i + 1, ( i + 1 ) + n, i + n );

            // ���̃����O
            for( uint i = 0; i < _desc.DivideCount; i++ )
				builder.�l�p�`��ǉ�����( i + n * 2, i + n * 3, ( i + 1 ) + n * 3, ( i + 1 ) + n * 2 );

            // ����
            for( uint i = 0; i < _desc.DivideCount; i++ )
				builder.�l�p�`��ǉ�����( i, i + n * 2, ( i + 1 ) + n * 2, ( i + 1 ) );

            // ����
            for( uint i = 0; i < _desc.DivideCount; i++ )
				builder.�l�p�`��ǉ�����( i + n, i + 1 + n, ( i + 1 ) + n * 3, i + n * 3 );
		}

		protected override void InitializePositions( List<Vector4> positions )
		{
			_�����O��ǉ�����( positions, 1, 1 );
			_�����O��ǉ�����( positions, 1, _desc.Thickness + 1f );
			_�����O��ǉ�����( positions, -1, 1 );
			_�����O��ǉ�����( positions, -1, _desc.Thickness + 1f );
		}


        private readonly SilinderShapeDescription _desc;

        private void _�����O��ǉ�����( List<Vector4> positions, float y, float r )
		{
			float stride = (float) ( 2 * Math.PI / _desc.DivideCount );

			for( int i = 0; i <= _desc.DivideCount; i++ )
				positions.Add( new Vector4( (float) ( Math.Cos( i * stride ) * r ), y, (float) ( Math.Sin( i * stride ) * r ), 1f ) );
		}
	}
}