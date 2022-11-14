/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('persona_rol_pertenencia_rel_tortura', {
		fk_persona_rol_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'persona_rol_pertenencia',
				key: 'id_persona_rol_pertenencia'
			}
		},
		fk_tortura_texto: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'tortura',
				key: 'texto'
			}
		}
	}, {
		tableName: 'persona_rol_pertenencia_rel_tortura',
		timestamps: false
	});
};
