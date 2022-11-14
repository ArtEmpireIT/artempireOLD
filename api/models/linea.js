/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('linea', {
		id_linea: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_linea::regclass)",
			primaryKey: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		estado: {
			type: DataTypes.STRING,
			allowNull: true
		},
		calidad: {
			type: DataTypes.STRING,
			allowNull: true
		},
		color: {
			type: DataTypes.STRING,
			allowNull: true
		},
		cantidad: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		tipo_impuesto: {
			type: DataTypes.STRING,
			allowNull: true
		},
		info_cont: {
			type: DataTypes.STRING,
			allowNull: true
		},
		compra_nomb: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_material_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'material',
				key: 'id_material'
			}
		},
		fk_agrupacion_bienes_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'agrupacion_bienes',
				key: 'id_agrupacion_bienes'
			}
		},
		fk_objeto_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'objeto',
				key: 'id_objeto'
			}
		},
		tipo_obj: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fecha: {
			type: DataTypes.DATE,
			allowNull: true
		},
		precision_fecha: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_lugar_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'lugar',
				key: 'id_lugar'
			}
		},
		precision_lugar: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'linea',
		timestamps: false
	});
};
