/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('persona_rol_pertenencia_rel_rol', {
		fk_rol_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'rol',
				key: 'nombre'
			}
		},
		fk_persona_rol_pertenencia: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'persona_rol_pertenencia',
				key: 'id_persona_rol_pertenencia'
			}
		}
	}, {
		tableName: 'persona_rol_pertenencia_rel_rol',
		timestamps: false
	});
};
