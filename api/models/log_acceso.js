/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('log_acceso', {
		id_log_acceso: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_log_acceso::regclass)",
			primaryKey: true
		},
		inicio_sesion: {
			type: DataTypes.TIME,
			allowNull: true
		},
		fin_sesion: {
			type: DataTypes.TIME,
			allowNull: true
		},
		fk_usuario: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'usuario',
				key: 'id_usuario'
			}
		},
		fecha: {
			type: DataTypes.DATE,
			allowNull: true
		},
		ip: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		token: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'log_acceso',
		timestamps: false
	});
};
