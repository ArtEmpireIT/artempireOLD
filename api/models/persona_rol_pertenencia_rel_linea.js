/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('persona_rol_pertenencia_rel_linea', {
		fk_persona_rol_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'persona_rol_pertenencia',
				key: 'id_persona_rol_pertenencia'
			}
		},
		fk_linea: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'linea',
				key: 'id_linea'
			}
		}
	}, {
		tableName: 'persona_rol_pertenencia_rel_linea',
		timestamps: false
	});
};
