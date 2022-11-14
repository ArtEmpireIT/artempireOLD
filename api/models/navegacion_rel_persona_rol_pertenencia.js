/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('navegacion_rel_persona_rol_pertenencia', {
		fk_persona_rol_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'persona_rol_pertenencia',
				key: 'id_persona_rol_pertenencia'
			}
		},
		fk_navegacion_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'navegacion',
				key: 'id_navegacion'
			}
		}
	}, {
		tableName: 'navegacion_rel_persona_rol_pertenencia',
		timestamps: false
	});
};
