using System.Collections.Generic;
using MikuMikuFlex.Utility;
using SharpDX;

namespace MikuMikuFlex.���f��.Shape
{
	public class �l�p���V�F�C�v : �V�F�C�v
	{
		public �l�p���V�F�C�v( Vector4 color )
            : base( color )
		{
		}

		public override string �t�@�C���� => "@@@ConeShape@@@";

		public override int ���_�� => 18;

		protected override void InitializeIndex( �C���f�b�N�X�o�b�t�@Builder builder )
		{
			builder.�l�p�`��ǉ�����( 4, 3, 2, 1 );
			builder.�O�p�`��ǉ�����( 0, 3, 4 );
			builder.�O�p�`��ǉ�����( 0, 2, 3 );
			builder.�O�p�`��ǉ�����( 0, 1, 2 );
			builder.�O�p�`��ǉ�����( 0, 4, 1 );
		}

		protected override void InitializePositions( List<Vector4> positions )
		{
			positions.Add( new Vector4( 0, 1, 0, 1 ) );
			positions.Add( new Vector4( -1, -1, 0, 1 ) );
			positions.Add( new Vector4( 0, -1, 1, 1 ) );
			positions.Add( new Vector4( 1, -1, 0, 1 ) );
			positions.Add( new Vector4( 0, -1, -1, 1 ) );
		}
	}
}