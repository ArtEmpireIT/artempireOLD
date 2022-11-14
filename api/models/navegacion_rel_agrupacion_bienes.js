/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('navegacion_rel_agrupacion_bienes', {
		fk_navegacion_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'navegacion',
				key: 'id_navegacion'
			}
		},
		fk_agrupacion_bienes_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'agrupacion_bienes',
				key: 'id_agrupacion_bienes'
			}
		}
	}, {
		tableName: 'navegacion_rel_agrupacion_bienes',
		timestamps: false
	});
};
