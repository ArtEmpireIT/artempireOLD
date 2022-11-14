/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('tortura', {
		texto: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		}
	}, {
		tableName: 'tortura',
		timestamps: false
	});
};
