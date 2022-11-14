/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('resto', {
		variable: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		avatar: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'resto',
		timestamps: false
	});
};
