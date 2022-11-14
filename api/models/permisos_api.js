/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('permisos_api', {
		id_permisos_api: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_permisos_api::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: false
		},
		crear: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		borrar: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		modificar: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		lectura: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		}
	}, {
		tableName: 'permisos_api',
		timestamps: false
	});
};
