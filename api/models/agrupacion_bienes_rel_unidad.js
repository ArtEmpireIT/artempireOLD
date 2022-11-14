/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('agrupacion_bienes_rel_unidad', {
		fk_agrupacion_bienes_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'agrupacion_bienes',
				key: 'id_agrupacion_bienes'
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
		}
	}, {
		tableName: 'agrupacion_bienes_rel_unidad',
		timestamps: false
	});
};
