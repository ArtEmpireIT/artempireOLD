/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('agrupacion_bienes', {
		id_agrupacion_bienes: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_agrupacion_bienes::regclass)",
			primaryKey: true
		},
		nombre: {
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
		adelanto_cont: {
			type: DataTypes.STRING,
			allowNull: true
		},
		descripcion_cont: {
			type: DataTypes.STRING,
			allowNull: true
		},
		folio_cont: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_metodo_pago_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'metodo_pago',
				key: 'id_metodo_pago'
			}
		},
		precision_lugar: {
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
		}
	}, {
		tableName: 'agrupacion_bienes',
		timestamps: false
	});
};
