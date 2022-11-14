/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('linea_rel_unidad', {
		fk_linea_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'linea',
				key: 'id_linea'
			}
		},
		fk_unidad_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'unidad',
				key: 'nombre'
			}
		},
		valor: {
			type: DataTypes.DOUBLE,
			allowNull: false
		},
		es_impuesto: {
			type: DataTypes.BOOLEAN,
			defaultValue: false
		}
	}, {
		tableName: 'linea_rel_unidad',
		timestamps: false
	});
};
