/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('persona_rol_pertenencia_rel_ocupacion', {
		fk_persona_rol_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'persona_rol_pertenencia',
				key: 'id_persona_rol_pertenencia'
			}
		},
		fk_ocupacion_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'ocupacion',
				key: 'nombre'
			}
		}
	}, {
		tableName: 'persona_rol_pertenencia_rel_ocupacion',
		timestamps: false
	});
};
