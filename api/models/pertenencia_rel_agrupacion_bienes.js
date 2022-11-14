/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('pertenencia_rel_agrupacion_bienes', {
		fk_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'pertenencia',
				key: 'id_pertenencia'
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
		tableName: 'pertenencia_rel_agrupacion_bienes',
		timestamps: false
	});
};
