/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('perfil_usuario_rel_permisos_api', {
		fk_perfil_usuario: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'perfil_usuario',
				key: 'id_perfil_usuario'
			}
		},
		fk_permisos_api: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'permisos_api',
				key: 'id_permisos_api'
			}
		}
	}, {
		tableName: 'perfil_usuario_rel_permisos_api',
		timestamps: false
	});
};
