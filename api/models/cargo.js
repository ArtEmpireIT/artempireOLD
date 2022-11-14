/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('cargo', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		}
	}, {
		tableName: 'cargo',
		timestamps: false
	});
};
