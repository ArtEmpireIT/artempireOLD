/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('persona_rol_pertenencia_rel_cargo', {
		fk_cargo_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'cargo',
				key: 'nombre'
			}
		},
		fk_persona_rol_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'persona_rol_pertenencia',
				key: 'id_persona_rol_pertenencia'
			}
		}
	}, {
		tableName: 'persona_rol_pertenencia_rel_cargo',
		timestamps: false
	});
};
