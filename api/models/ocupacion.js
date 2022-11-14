/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('ocupacion', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		}
	}, {
		tableName: 'ocupacion',
		timestamps: false
	});
};
