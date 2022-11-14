/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('miembro', {
		texto: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		}
	}, {
		tableName: 'miembro',
		timestamps: false
	});
};
