/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('perfil_usuario', {
		id_perfil_usuario: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_perfil_usuario::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'perfil_usuario',
		timestamps: false
	});
};
