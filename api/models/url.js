/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('url', {
		id_url: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_url::regclass)",
			primaryKey: true
		},
		url: {
			type: DataTypes.STRING,
			allowNull: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		motivo_conf: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'url',
		timestamps: false
	});
};
