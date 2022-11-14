/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('documento', {
		id_documento: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_documento::regclass)",
			primaryKey: true
		},
		version_doc: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		titulo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		foliado: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		des_foliado: {
			type: DataTypes.STRING,
			allowNull: true
		},
		firmada: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		holografa: {
			type: DataTypes.STRING,
			allowNull: true
		},
		resumen: {
			type: DataTypes.STRING,
			allowNull: true
		},
		transcripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		transcripcion_tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		adelanto_cont: {
			type: DataTypes.STRING,
			allowNull: true
		},
		soporte: {
			type: DataTypes.STRING,
			allowNull: true
		},
		migracion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fecha_confi_datos: {
			type: DataTypes.DATE,
			allowNull: true
		},
		fecha_confi_img: {
			type: DataTypes.DATE,
			allowNull: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		subtipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		motivo_almoneda: {
			type: DataTypes.STRING,
			allowNull: true
		},
		preambulo_testamento: {
			type: DataTypes.STRING,
			allowNull: true
		},
		disp_ente_testamento: {
			type: DataTypes.STRING,
			allowNull: true
		},
		diligencias_visita: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_usuario_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'usuario',
				key: 'id_usuario'
			}
		},
		fk_seccion_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'seccion',
				key: 'id_seccion'
			}
		},
		fk_pena_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'pena',
				key: 'id_pena'
			}
		},
		signatura: {
			type: DataTypes.STRING,
			allowNull: true
		},
		confidencial_datos: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		confidencial_img: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		}
	}, {
		tableName: 'documento',
		timestamps: false
	});
};
